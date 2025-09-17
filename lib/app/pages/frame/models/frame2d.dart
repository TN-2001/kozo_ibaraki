import 'dart:io';
import 'dart:math';

/// 「dart run frame2d.dart」で実行

Map<String, Object> frame2d(Map<String, Object> input) {
  List<List<int>> ijk0 = [];
  List<List<int>> ijke = [];
  List<List<int>> mfix = [];
  List<int> mdof = [];
  List<List<List<int>>> mhng = [];
  List<int> ndiv = [];
  
  List<List<double>> xyz0 = [];
  List<List<double>> xyzn = [];
  List<List<double>> prp0 = [];
  List<List<double>> prop = [];
  List<List<double>> fnod = [];
  List<double> felm = [];
  List<List<List<double>>> vske = [];
  List<double> fext = [];
  List<double> frea = [];
  List<double> disp = [];
  
  // CGM
  List<double> diag = [];
  List<double> cgw1 = [];
  List<double> cgw2 = [];
  List<double> cgw3 = [];
  
  // Results
  List<List<double>> fint = []; // 0:Se, 1: Ma, 2:Mb
  
  // Problem parameters
  int nx = 0;
  int nelx = 0;
  int nx2 = 0;
  int nelx2 = 0;
  int neq = 0;
  int nhng = 0;
  int node = 2;
  int ndof = 3;

  nx = input['nx'] as int;
  xyz0 = input['xyz0'] as List<List<double>>;
  mfix = input['mfix'] as List<List<int>>;
  fnod = input['fnod'] as List<List<double>>;
  nelx = input['nelx'] as int;
  ijk0 = input['ijk0'] as List<List<int>>;
  prp0 = input['prp0'] as List<List<double>>;
  felm = input['felm'] as List<double>;

  ndiv = List<int>.filled(nelx, 0);

  // Count hinges
  nhng = 0;
  for (int i = 0; i < nx; i++) {
    if (mfix[i][3] == 1) nhng++;
  }

  void remesh() {
    // print('\n(*) REMESH -----');
    
    // Calculate maximum element size and division
    double hmax = 0.0;
    for (int ie = 0; ie < nelx; ie++) {
      int n1 = ijk0[ie][0];
      int n2 = ijk0[ie][1];
      double x1 = xyz0[n1][0];
      double y1 = xyz0[n1][1];
      double x2 = xyz0[n2][0];
      double y2 = xyz0[n2][1];
      double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
      hmax += he;
    }
    double dhe = hmax / 100;
    
    // Calculate division numbers
    for (int ie = 0; ie < nelx; ie++) {
      int n1 = ijk0[ie][0];
      int n2 = ijk0[ie][1];
      double x1 = xyz0[n1][0];
      double y1 = xyz0[n1][1];
      double x2 = xyz0[n2][0];
      double y2 = xyz0[n2][1];
      double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
      ndiv[ie] = (he / dhe).truncate(); // 小数点以下切り捨て
    }
    
    // Calculate new number of elements and nodes
    nelx2 = 0;
    for (int ie = 0; ie < nelx; ie++) {
      nelx2 += ndiv[ie];
    }
    nx2 = nelx2 + 1;
    neq = ndof * nx2 + nhng;
    
    // Initialize new arrays
    ijke = List.generate(nelx2, (_) => List<int>.filled(2, 0));
    xyzn = List.generate(nx2, (_) => List<double>.filled(2, 0.0));
    prop = List.generate(nelx2, (_) => List<double>.filled(3, 0.0));
    
    // Create new nodes
    int kn = nx;
    for (int ie = 0; ie < nelx; ie++) {
      int n1 = ijk0[ie][0];
      int n2 = ijk0[ie][1];
      double x1 = xyz0[n1][0];
      double y1 = xyz0[n1][1];
      double x2 = xyz0[n2][0];
      double y2 = xyz0[n2][1];
      // double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
      for (int je = 1; je < ndiv[ie]; je++) {
        double dx = (x2 - x1) / ndiv[ie];
        double dy = (y2 - y1) / ndiv[ie];
        xyzn[kn][0] = x1 + dx * je;
        xyzn[kn][1] = y1 + dy * je;
        kn++;
      }
    }
    
    // Copy original nodes
    for (int i = 0; i < nx; i++) {
      xyzn[i][0] = xyz0[i][0];
      xyzn[i][1] = xyz0[i][1];
    }
    
    // Create new elements
    int ke = 0;
    kn = nx;
    for (int ie = 0; ie < nelx; ie++) {
      for (int je = 0; je < ndiv[ie]; je++) {
        prop[ke][0] = prp0[ie][0];
        prop[ke][1] = prp0[ie][1];
        prop[ke][2] = prp0[ie][2];
        
        if (je == 0) {
          ijke[ke][0] = ijk0[ie][0];
          ijke[ke][1] = kn;
          kn++;
        } else if (je == ndiv[ie] - 1) {
          ijke[ke][0] = kn - 1;
          ijke[ke][1] = ijk0[ie][1];
        } else {
          ijke[ke][0] = kn - 1;
          ijke[ke][1] = kn;
          kn++;
        }
        ke++;
      }
    }

    // Initialize arrays
    mdof = List<int>.filled(neq, 0);
    fext = List<double>.filled(neq, 0.0);
    disp = List<double>.filled(neq, 0.0);
    frea = List<double>.filled(neq, 0.0);
    diag = List<double>.filled(neq, 0.0);
    cgw1 = List<double>.filled(neq, 0.0);
    cgw2 = List<double>.filled(neq, 0.0);
    cgw3 = List<double>.filled(neq, 0.0);
    
    // Initialize element matrices
    vske = List.generate(nelx2, (_) => 
      List.generate(6, (_) => List<double>.filled(6, 0.0)));
    fint = List.generate(nelx2, (_) => List<double>.filled(3, 0.0));
    mhng = List.generate(nelx2, (_) => 
      List.generate(node, (_) => List<int>.filled(ndof, 0)));
  }

  void setupDOFTable() {
    // print('\n(*) DOFTAB -----');
    
    // DOF table for constraints
    for (int i = 0; i < neq; i++) {
      mdof[i] = 1;
    }
    for (int ix = 0; ix < nx; ix++) {
      if (mfix[ix][0] == 1) mdof[ndof * ix + 0] = 0;
      if (mfix[ix][1] == 1) mdof[ndof * ix + 1] = 0;
      if (mfix[ix][2] == 1) mdof[ndof * ix + 2] = 0;
    }
    
    // DOF table for middle-hinge
    for (int ie = 0; ie < nelx2; ie++) {
      for (int jn = 0; jn < node; jn++) {
        for (int kd = 0; kd < ndof; kd++) {
          mhng[ie][jn][kd] = ndof * ijke[ie][jn] + kd;
        }
      }
    }
    
    // Consider middle-hinge
    int ihng = 0;
    for (int ix = 0; ix < nx; ix++) {
      if (mfix[ix][3] == 1) {
        bool iend = false;
        for (int je = 0; je < nelx2 && !iend; je++) {
          for (int jn = 0; jn < node; jn++) {
            if (ijke[je][jn] == ix) {
              mhng[je][jn][2] = ndof * nx2 + ihng;
              iend = true;
              break;
            }
          }
        }
        ihng++;
      }
    }
  }

  void assembleMatrix() {
    // print('\n(*) MATRIX -----');
    
    // Assemble stiffness matrix
    for (int ie = 0; ie < nelx2; ie++) {
      double ei = prop[ie][0] * prop[ie][1];
      double ea = prop[ie][0] * prop[ie][2];
      int n1 = ijke[ie][0];
      int n2 = ijke[ie][1];
      double x1 = xyzn[n1][0];
      double y1 = xyzn[n1][1];
      double x2 = xyzn[n2][0];
      double y2 = xyzn[n2][1];
      double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
      double cc = (x2 - x1) / he; // cos
      double ss = (y2 - y1) / he; // sin
      
      // Local stiffness matrix
      List<List<double>> ske = List.generate(6, (_) => List<double>.filled(6, 0.0));
      ske[0][0] = ea / he;
      ske[0][3] = -ea / he;
      ske[1][1] = 12.0 * ei / pow(he, 3);
      ske[1][2] = 6.0 * he * ei / pow(he, 3);
      ske[1][4] = -12.0 * ei / pow(he, 3);
      ske[1][5] = 6.0 * he * ei / pow(he, 3);
      ske[2][1] = 6.0 * he * ei / pow(he, 3);
      ske[2][2] = 4.0 * pow(he, 2) * ei / pow(he, 3);
      ske[2][4] = -6.0 * he * ei / pow(he, 3);
      ske[2][5] = 2.0 * pow(he, 2) * ei / pow(he, 3);
      ske[3][0] = -ea / he;
      ske[3][3] = ea / he;
      ske[4][1] = -12.0 * ei / pow(he, 3);
      ske[4][2] = -6.0 * he * ei / pow(he, 3);
      ske[4][4] = 12.0 * ei / pow(he, 3);
      ske[4][5] = -6.0 * he * ei / pow(he, 3);
      ske[5][1] = 6.0 * he * ei / pow(he, 3);
      ske[5][2] = 2.0 * pow(he, 2) * ei / pow(he, 3);
      ske[5][4] = -6.0 * he * ei / pow(he, 3);
      ske[5][5] = 4.0 * pow(he, 2) * ei / pow(he, 3);
      
      // Transformation matrix
      List<List<double>> tre = List.generate(6, (_) => List<double>.filled(6, 0.0));
      tre[0][0] = cc;
      tre[0][1] = ss;
      tre[1][0] = -ss;
      tre[1][1] = cc;
      tre[2][2] = 1.0;
      tre[3][3] = cc;
      tre[3][4] = ss;
      tre[4][3] = -ss;
      tre[4][4] = cc;
      tre[5][5] = 1.0;
      
      // Transform stiffness matrix
      for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
          vske[ie][i][j] = 0.0;
        }
      }
      for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
          for (int k = 0; k < 6; k++) {
            for (int l = 0; l < 6; l++) {
              vske[ie][i][j] += tre[k][i] * ske[k][l] * tre[l][j];
            }
          }
        }
      }
    }
    
    // Assemble distributed load vector
    for (int i = 0; i < fext.length; i++) {
      fext[i] = 0.0;
    }
    int ke = 0;
    for (int ie = 0; ie < nelx; ie++) {
      double we = felm[ie];
      for (int je = 0; je < ndiv[ie]; je++) {
        int n1 = ijke[ke][0];
        int n2 = ijke[ke][1];
        double x1 = xyzn[n1][0];
        double y1 = xyzn[n1][1];
        double x2 = xyzn[n2][0];
        double y2 = xyzn[n2][1];
        double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
        double cc = (x2 - x1) / he;
        double ss = (y2 - y1) / he;
        
        double f1 = 0.0;
        double f2 = we * he / 2.0;
        double f3 = we * he / 2.0 * he / 6.0;
        double f4 = 0.0;
        double f5 = we * he / 2.0;
        double f6 = -we * he / 2.0 * he / 6.0;
        
        fext[mhng[ke][0][0]] += cc * f1 - ss * f2;
        fext[mhng[ke][0][1]] += ss * f1 + cc * f2;
        fext[mhng[ke][0][2]] += f3;
        fext[mhng[ke][1][0]] += cc * f4 - ss * f5;
        fext[mhng[ke][1][1]] += ss * f4 + cc * f5;
        fext[mhng[ke][1][2]] += f6;
        ke++;
      }
    }
    
    // Point (nodal) load
    for (int ix = 0; ix < nx; ix++) {
      fext[ndof * ix + 0] += fnod[ix][0];
      fext[ndof * ix + 1] += fnod[ix][1];
      if (mfix[ix][3] == 0) {
        fext[ndof * ix + 2] += fnod[ix][2];
      }
    }

    // Displacement vector
    for (int i = 0; i < disp.length; i++) {
      disp[i] = 0.0;
    }
  }

  void solveCGM() {
    // print('\n(*) SOLVER -----');

    double dotProduct(List<double> a, List<double> b) {
      double sum = 0.0;
      for (int i = 0; i < a.length; i++) {
        sum += a[i] * b[i];
      }
      return sum;
    }
    
    // Diagonal scaling
    for (int i = 0; i < neq; i++) {
      cgw1[i] = 0.0;
      cgw2[i] = 0.0;
      diag[i] = 0.0;
    }
    for (int ie = 0; ie < nelx2; ie++) {
      for (int io = 0; io < node; io++) {
        for (int id = 0; id < ndof; id++) {
          int ii = ndof * io + id;
          int ig = mhng[ie][io][id];
          diag[ig] += vske[ie][ii][ii];
        }
      }
    }
    
    for (int i = 0; i < neq; i++) {
      double dv = diag[i].abs();
      if (dv > 1e-9) {
        diag[i] = 1.0 / sqrt(dv);
      } else {
        diag[i] = 1.0;
      }
    }
    
    // Initialize CGM vectors
    for (int i = 0; i < neq; i++) {
      if (mdof[i] >= 1) {
        cgw1[i] = fext[i] * diag[i];
        cgw2[i] = cgw1[i];
      }
    }
    
    double r0r0 = dotProduct(cgw1, cgw1);
    
    // CGM iteration
    for (int kcg = 0; kcg < neq * 10; kcg++) {
      // Matrix-vector multiplication
      cgw3.fillRange(0, neq, 0.0);
      for (int ie = 0; ie < nelx2; ie++) {
        for (int io = 0; io < node; io++) {
          for (int id = 0; id < ndof; id++) {
            int ii = ndof * io + id;
            int ig = mhng[ie][io][id];
            double di = diag[ig];
            
            if (mdof[ig] >= 1) {
              for (int ko = 0; ko < node; ko++) {
                for (int kd = 0; kd < ndof; kd++) {
                  int kk = ndof * ko + kd;
                  int kg = mhng[ie][ko][kd];
                  double dk = diag[kg];
                  cgw3[ig] += di * dk * vske[ie][ii][kk] * cgw2[kg];
                }
              }
            }
          }
        }
      }
      
      double app = dotProduct(cgw3, cgw2);
      double rr = dotProduct(cgw1, cgw1);
      double alph = rr / app;
      
      for (int i = 0; i < neq; i++) {
        disp[i] += alph * cgw2[i];
        cgw1[i] -= alph * cgw3[i];
      }
      
      double r1r1 = dotProduct(cgw1, cgw1);
      if (r1r1 < 1e-99) r1r1 = 1e-9;
      
      // print('${kcg + 1}) ${sqrt(rr / r0r0).toStringAsExponential(5)} ${r1r1.toStringAsExponential(5)}');
      
      if (sqrt(rr / r0r0) < 1e-9) {
        for (int i = 0; i < neq; i++) {
          disp[i] *= diag[i];
          if (disp[i].abs() < 1e-9) disp[i] = 0.0;
        }
        break;
      } else {
        double beta = r1r1 / rr;
        for (int i = 0; i < neq; i++) {
          cgw2[i] = cgw1[i] + beta * cgw2[i];
        }
      }
    }
  }

  void postProcess() {
    // print('\n(*) POSTPR -----');
    
    // Calculate shear force and bending moment
    for (int ie = 0; ie < nelx2; ie++) {
      double ei = prop[ie][0] * prop[ie][1];
      double ea = prop[ie][0] * prop[ie][2];
      int n1 = ijke[ie][0];
      int n2 = ijke[ie][1];
      double x1 = xyzn[n1][0];
      double y1 = xyzn[n1][1];
      double x2 = xyzn[n2][0];
      double y2 = xyzn[n2][1];
      double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
      double cc = (x2 - x1) / he;
      double ss = (y2 - y1) / he;
      
      double u1 = cc * disp[mhng[ie][0][0]] + ss * disp[mhng[ie][0][1]];
      double v1 = -ss * disp[mhng[ie][0][0]] + cc * disp[mhng[ie][0][1]];
      double q1 = disp[mhng[ie][0][2]];
      double u2 = cc * disp[mhng[ie][1][0]] + ss * disp[mhng[ie][1][1]];
      double v2 = -ss * disp[mhng[ie][1][0]] + cc * disp[mhng[ie][1][1]];
      double q2 = disp[mhng[ie][1][2]];
      
      double pe = ea * (u2 - u1) / he;
      double se = -ei / pow(he, 2) * (12.0 / he * v1 + 6.0 * q1 - 12.0 / he * v2 + 6.0 * q2);
      double b1 = ei / he * (-6.0 / he * v1 - 4.0 * q1 + 6.0 / he * v2 - 2.0 * q2);
      double b2 = ei / he * (6.0 / he * v1 + 2.0 * q1 - 6.0 / he * v2 + 4.0 * q2);
      
      fint[ie][0] = pe;
      fint[ie][1] = -se;
      fint[ie][2] = (b1 + b2) / 2.0;
    }
    
    // Calculate reaction forces
    for (int i = 0; i < frea.length; i++) {
      frea[i] = 0.0;
    }
    for (int ie = 0; ie < nelx2; ie++) {
      for (int io = 0; io < node; io++) {
        for (int id = 0; id < ndof; id++) {
          int ii = ndof * io + id;
          int ig = mhng[ie][io][id];
          
          for (int ko = 0; ko < node; ko++) {
            for (int kd = 0; kd < ndof; kd++) {
              int kk = ndof * ko + kd;
              int kg = mhng[ie][ko][kd];
              frea[ig] += vske[ie][ii][kk] * disp[kg];
            }
          }
        }
      }
    }
    
    for (int i = 0; i < neq; i++) {
      frea[i] -= fext[i];
    }
  }

  remesh();
  setupDOFTable();
  assembleMatrix();
  solveCGM();
  postProcess();

  return {
    'nx' : nx,
    'nx2' : nx2,
    'xyzn' : xyzn,
    'nelx2' : nelx2,
    'ndof' : ndof,
    'node' : node,
    'disp' : disp,
    'ijke' : ijke,
    'mfix' : mfix,
    'mhng' : mhng,
    'fint' : fint,
    'frea' : frea,
  };
}

Future<Map<String, Object>> _readInput() async {
  // print('\n(*) READ -----');
  
  final file = File('inpframe.txt');
  final lines = await file.readAsLines();
  int lineIndex = 0;
  
  // Skip NODE comment
  lineIndex++;
  
  // Read number of nodes
  final int nx = int.parse(lines[lineIndex++].substring(0,7));
  
  // Initialize arrays
  final List<List<double>> xyz0 = List.generate(nx, (_) => List<double>.filled(2, 0.0));
  final List<List<int>> mfix = List.generate(nx, (_) => List<int>.filled(4, 0));
  final List<List<double>> fnod = List.generate(nx, (_) => List<double>.filled(3, 0.0));
  
  // Read node data
  for (int i = 0; i < nx; i++) {
    final parts = lines[lineIndex++].split(RegExp(r'\s+'));
    int partIndex = 2; // Skip node number
    xyz0[i][0] = double.parse(parts[partIndex++]);
    xyz0[i][1] = double.parse(parts[partIndex++]);
    mfix[i][0] = int.parse(parts[partIndex++]);
    mfix[i][1] = int.parse(parts[partIndex++]);
    mfix[i][2] = int.parse(parts[partIndex++]);
    fnod[i][0] = double.parse(parts[partIndex++]);
    fnod[i][1] = double.parse(parts[partIndex++]);
    fnod[i][2] = double.parse(parts[partIndex++]);
    mfix[i][3] = int.parse(parts[partIndex++]);
  }
  
  // Skip ELEMENT comment
  lineIndex++;
  
  // Read number of elements
  final int nelx = int.parse(lines[lineIndex++].substring(0,7));
  
  // Initialize element arrays
  final List<List<int>> ijk0 = List.generate(nelx, (_) => List<int>.filled(2, 0));
  final List<List<double>> prp0 = List.generate(nelx, (_) => List<double>.filled(3, 0.0));
  final List<double> felm = List<double>.filled(nelx, 0.0);
  
  // Read element data
  for (int i = 0; i < nelx; i++) {
    final parts = lines[lineIndex++].split(RegExp(r'\s+'));
    int partIndex = 2; // Skip element number
    ijk0[i][0] = int.parse(parts[partIndex++]) - 1; // Convert to 0-based
    ijk0[i][1] = int.parse(parts[partIndex++]) - 1;
    prp0[i][0] = double.parse(parts[partIndex++]);
    prp0[i][1] = double.parse(parts[partIndex++]);
    prp0[i][2] = double.parse(parts[partIndex++]);
    felm[i] = double.parse(parts[partIndex++]);
  }

  return {
    'nx': nx,
    'xyz0': xyz0,
    'mfix': mfix,
    'fnod': fnod,
    'nelx': nelx,
    'ijk0': ijk0,
    'prp0': prp0,
    'felm': felm,
  };
}

Future<void> _writeOutput(Map<String, Object> output) async {
  // print('\n(*) WRITE -----');

  final int nx = output['nx'] as int;
  final int nelx2 = output['nelx2'] as int;
  final int ndof = output['ndof'] as int;
  final int node = output['node'] as int;
  final List<double> disp = output['disp'] as List<double>;
  final List<List<int>> ijke = output['ijke'] as List<List<int>>;
  final List<List<int>> mfix = output['mfix'] as List<List<int>>;
  final List<List<List<int>>> mhng = output['mhng'] as List<List<List<int>>>;
  final List<List<double>> fint = output['fint'] as List<List<double>>;
  final List<double> frea = output['frea'] as List<double>;
  
  final outputFile = File('resframe.txt');
  final sink = outputFile.openWrite();
  
  // Output displacement
  sink.writeln('*displacement (e, n, u, v, q) ---');
  for (int ie = 0; ie < nelx2; ie++) {
    for (int jn = 0; jn < node; jn++) {
      double ui = disp[mhng[ie][jn][0]];
      double vi = disp[mhng[ie][jn][1]];
      double qi = disp[mhng[ie][jn][2]];
      sink.writeln('${(ie + 1).toString().padLeft(5)} ${(ijke[ie][jn] + 1).toString().padLeft(5)} ${ui.toStringAsExponential(5)} ${vi.toStringAsExponential(5)} ${qi.toStringAsExponential(5)}');
    }
  }
  sink.writeln('');
  
  // Output internal force
  sink.writeln('*internal force (e, N, S, M) ----');
  for (int ie = 0; ie < nelx2; ie++) {
    sink.writeln('${(ie + 1).toString().padLeft(5)} ${fint[ie][0].toStringAsExponential(5)} ${fint[ie][1].toStringAsExponential(5)} ${fint[ie][2].toStringAsExponential(5)}');
  }
  sink.writeln('');
  
  // Output reaction force
  sink.writeln('*reaction force -----------------');
  for (int ix = 0; ix < nx; ix++) {
    if (mfix[ix][0] == 1) {
      sink.writeln('${(ix + 1).toString().padLeft(5)}    H ${frea[ndof * ix + 0].toStringAsExponential(5)}');
    }
    if (mfix[ix][1] == 1) {
      sink.writeln('${(ix + 1).toString().padLeft(5)}    V ${frea[ndof * ix + 1].toStringAsExponential(5)}');
    }
    if (mfix[ix][2] == 1 && mfix[ix][3] == 0) {
      sink.writeln('${(ix + 1).toString().padLeft(5)}    M ${frea[ndof * ix + 2].toStringAsExponential(5)}');
    }
  }
  
  await sink.close();
}

void main() async {
  final input = await _readInput();
  final output = frame2d(input);
  await _writeOutput(output);
}