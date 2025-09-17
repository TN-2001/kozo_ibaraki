import 'dart:io';
import 'dart:math';

/// input
/// int nx                  : 節点数
/// List<List<double>> xyzn : 節点座標
/// List<List<int>> mfix    : 節点拘束条件  
/// List<List<double>> fnod : 節点荷重
/// int nelx                : 要素数
/// List<List<int>> ijke    : 要素接続情報
/// List<List<double>> prop : 要素材料特性

/// output
/// int nx                  : 節点数
/// int nelx                : 要素数
/// int ndof                : 自由度数
/// List<double> disp       : 節点変位
/// List<List<int>> mfix    : 節点拘束条件
/// List<List<double>> prop : 要素材料特性
/// List<double> fint       : 要素内力（軸力）
/// List<double> frea       : 節点反力

/// 「dart run truss2d.dart」で実行
/// 以下のような入力ファイル（inptruss.txt）が必要
/// ```txt
/// /NODE/
///     3       x       y      fx fy      Px      Py
///     1     0.0     0.0       1  1     0.0     0.0
///     2     6.0     0.0       0  1     0.0     0.0
///     3     0.0     6.0       0  0     6.0     0.0
/// /TRUS/
///     3    a    b       E       A
///     1    1    2     3.0     2.0
///     2    1    3     3.0     2.0
///     3    2    3     3.0     2.0
/// /ENDOF/
/// ```


Map<String, Object> truss2d(Map<String, Object> input) {
  // Node and element data
  late int nx, nelx;
  late List<List<double>> xyzn; // Node coordinates
  late List<List<int>> ijke;    // Element connectivity (IJK)
  late List<List<int>> mfix;    // Boundary conditions (1: x, 2: y)
  late List<List<double>> prop; // Element properties (E, A)
  late List<List<double>> fnod; // Nodal loads (x, y)
  
  // System data
  late int node, ndof, neq;
  late List<int> mdof;          // DOF table for constraints
  late List<double> fext;       // External force vector
  late List<double> disp;       // Displacement vector
  late List<double> frea;       // Reaction force vector
  
  // Element stiffness matrices
  late List<List<List<double>>> vske;
  
  // CGM solver arrays
  late List<double> diag, cgw1, cgw2, cgw3;
  
  // Results
  late List<double> fint; // Axial forces


  nx = input['nx'] as int;
  xyzn = input['xyzn'] as List<List<double>>;
  mfix = input['mfix'] as List<List<int>>;
  fnod = input['fnod'] as List<List<double>>;
  nelx = input['nelx'] as int;
  ijke = input['ijke'] as List<List<int>>;
  prop = input['prop'] as List<List<double>>;

  // System parameters
  node = 2;
  ndof = 2;
  neq = ndof * nx;
  
  // Allocate remaining arrays
  mdof = List.filled(neq, 1);
  fext = List.filled(neq, 0.0);
  disp = List.filled(neq, 0.0);
  frea = List.filled(neq, 0.0);
  diag = List.filled(neq, 0.0);
  cgw1 = List.filled(neq, 0.0);
  cgw2 = List.filled(neq, 0.0);
  cgw3 = List.filled(neq, 0.0);
  vske = List.generate(nelx, (_) => List.generate(4, (_) => List.filled(4, 0.0)));
  fint = List.filled(nelx, 0.0);


  // print('(*) DOFTAB -----');
    
  // DOF table (for constraint)
  for (int ix = 0; ix < nx; ix++) {
    if (mfix[ix][0] == 1) mdof[ndof * ix + 0] = 0;
    if (mfix[ix][1] == 1) mdof[ndof * ix + 1] = 0;
  }

  // print('(*) MATRIX -----');
    
  // Element stiffness matrices
  for (int ie = 0; ie < nelx; ie++) {
    double ea = prop[ie][0] * prop[ie][1];
    int n1 = ijke[ie][0];
    int n2 = ijke[ie][1];
    double x1 = xyzn[n1][0];
    double y1 = xyzn[n1][1];
    double x2 = xyzn[n2][0];
    double y2 = xyzn[n2][1];
    double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2)); // length
    double cc = (x2 - x1) / he; // cos
    double ss = (y2 - y1) / he; // sin
    
    // Element stiffness matrix
    vske[ie][0][0] =  ea/he * cc * cc;
    vske[ie][0][1] =  ea/he * cc * ss;
    vske[ie][0][2] = -ea/he * cc * cc;
    vske[ie][0][3] = -ea/he * cc * ss;
    vske[ie][1][0] =  ea/he * cc * ss;
    vske[ie][1][1] =  ea/he * ss * ss;
    vske[ie][1][2] = -ea/he * cc * ss;
    vske[ie][1][3] = -ea/he * ss * ss;
    vske[ie][2][0] = -ea/he * cc * cc;
    vske[ie][2][1] = -ea/he * cc * ss;
    vske[ie][2][2] =  ea/he * cc * cc;
    vske[ie][2][3] =  ea/he * cc * ss;
    vske[ie][3][0] = -ea/he * cc * ss;
    vske[ie][3][1] = -ea/he * ss * ss;
    vske[ie][3][2] =  ea/he * cc * ss;
    vske[ie][3][3] =  ea/he * ss * ss;
  }

  // Point (nodal) load
  for (int ix = 0; ix < nx; ix++) {
    fext[ndof * ix + 0] = fnod[ix][0];
    fext[ndof * ix + 1] = fnod[ix][1];
  }

  // print('(*) SOLVER -----');
    
  // Diagonal scaling
  for (int ie = 0; ie < nelx; ie++) {
    for (int io = 0; io < node; io++) {
      int ic = ijke[ie][io];
      for (int id = 0; id < ndof; id++) {
        int ii = ndof * io + id;
        int ig = ndof * ic + id;
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
  
  double r0r0 = _dotProduct(cgw1, cgw1);
  
  // CGM iteration
  for (int kcg = 1; kcg <= neq * 10; kcg++) {
    // Matrix-vector multiplication
    cgw3.fillRange(0, neq, 0.0);
    for (int ie = 0; ie < nelx; ie++) {
      for (int io = 0; io < node; io++) {
        int ic = ijke[ie][io];
        for (int id = 0; id < ndof; id++) {
          int ii = ndof * io + id;
          int ig = ndof * ic + id;
          double di = diag[ig];
          
          if (mdof[ig] >= 1) {
            for (int ko = 0; ko < node; ko++) {
              int kc = ijke[ie][ko];
              for (int kd = 0; kd < ndof; kd++) {
                int kk = ndof * ko + kd;
                int kg = ndof * kc + kd;
                double dk = diag[kg];
                cgw3[ig] += di * dk * vske[ie][ii][kk] * cgw2[kg];
              }
            }
          }
        }
      }
    }
    
    // Dot products and update
    double app = _dotProduct(cgw3, cgw2);
    double rr = _dotProduct(cgw1, cgw1);
    double alph = rr / app;
    
    for (int i = 0; i < neq; i++) {
      disp[i] += alph * cgw2[i];
      cgw1[i] -= alph * cgw3[i];
    }
    
    double r1r1 = _dotProduct(cgw1, cgw1);
    if (r1r1 < 1e-99) r1r1 = 1e-9;
    
    // Output convergence check
    // print('${kcg.toString().padLeft(8)}) ${(sqrt(rr/r0r0)).toStringAsExponential(5)} ${r1r1.toStringAsExponential(5)}');
    
    // Check convergence
    if (sqrt(rr/r0r0) < 1e-11) {
      for (int i = 0; i < neq; i++) {
        disp[i] *= diag[i];
      }
      break;
    } else {
      double beta = r1r1 / rr;
      for (int i = 0; i < neq; i++) {
        cgw2[i] = cgw1[i] + beta * cgw2[i];
      }
    }
    
    if (kcg >= neq * 10) {
      throw Exception('ERROR! (CGM)');
    }
  }

  // print('(*) POSTPR -----');
    
  // Axial force (normal force)
  for (int ie = 0; ie < nelx; ie++) {
    double ea = prop[ie][0] * prop[ie][1];
    int n1 = ijke[ie][0];
    int n2 = ijke[ie][1];
    double x1 = xyzn[n1][0];
    double y1 = xyzn[n1][1];
    double x2 = xyzn[n2][0];
    double y2 = xyzn[n2][1];
    double he = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2)); // length
    double cc = (x2 - x1) / he; // cos
    double ss = (y2 - y1) / he; // sin
    
    double u1 = disp[ndof * n1 + 0];
    double v1 = disp[ndof * n1 + 1];
    double u2 = disp[ndof * n2 + 0];
    double v2 = disp[ndof * n2 + 1];
    
    double t1 = -cc*cc*cc - cc*ss*ss;
    double t2 = -cc*cc*ss - ss*ss*ss;
    double t3 =  cc*cc*cc + cc*ss*ss;
    double t4 =  cc*cc*ss + ss*ss*ss;
    
    fint[ie] = ea/he * (t1*u1 + t2*v1 + t3*u2 + t4*v2);
  }
  
  // Reaction force
  frea.fillRange(0, neq, 0.0);
  for (int ie = 0; ie < nelx; ie++) {
    for (int io = 0; io < node; io++) {
      int ic = ijke[ie][io];
      for (int id = 0; id < ndof; id++) {
        int ii = ndof * io + id;
        int ig = ndof * ic + id;
        
        for (int ko = 0; ko < node; ko++) {
          int kc = ijke[ie][ko];
          for (int kd = 0; kd < ndof; kd++) {
            int kk = ndof * ko + kd;
            int kg = ndof * kc + kd;
            frea[ig] += vske[ie][ii][kk] * disp[kg];
          }
        }
      }
    }
  }
  
  for (int i = 0; i < neq; i++) {
    frea[i] -= fext[i];
  }

  return {
    'nx' : nx,
    'nelx' : nelx,
    'ndof' : ndof,
    'disp' : disp,
    'mfix' : mfix,
    'prop' : prop,
    'fint' : fint,
    'frea' : frea,
  };
}

double _dotProduct(List<double> a, List<double> b) {
  double result = 0.0;
  for (int i = 0; i < a.length; i++) {
    result += a[i] * b[i];
  }
  return result;
}

Future<Map<String, Object>> _readInput() async {
  // print('(*) READ -----');
  
  final inputFile = File('inptruss.txt');
  final lines = await inputFile.readAsLines();
  
  int lineIndex = 0;
  
  // Skip NODE header and read number of nodes
  lineIndex++; // Skip NODE
  final int nx = int.parse(lines[lineIndex++].substring(0,7));
  
  // Initialize arrays
  final List<List<double>> xyzn = List.generate(nx, (_) => List.filled(2, 0.0));
  final List<List<int>> mfix = List.generate(nx, (_) => List.filled(2, 0));
  final List<List<double>> fnod = List.generate(nx, (_) => List.filled(2, 0.0));

  // Read node data
  for (int i = 0; i < nx; i++) {
    final parts = lines[lineIndex++].split(RegExp(r'\s+'));
    // int n0 = int.parse(parts[1]);
    xyzn[i][0] = double.parse(parts[2]);
    xyzn[i][1] = double.parse(parts[3]);
    mfix[i][0] = int.parse(parts[4]);
    mfix[i][1] = int.parse(parts[5]);
    fnod[i][0] = double.parse(parts[6]);
    fnod[i][1] = double.parse(parts[7]);
  }
  
  // Skip ELEMENT header and read number of elements
  lineIndex++; // Skip ELEMENT
  final int nelx = int.parse(lines[lineIndex++].substring(0,7));
  
  // Initialize element arrays
  final List<List<int>> ijke = List.generate(nelx, (_) => List.filled(2, 0));
  final List<List<double>> prop = List.generate(nelx, (_) => List.filled(2, 0.0));
  
  // Read element data
  for (int i = 0; i < nelx; i++) {
    final parts = lines[lineIndex++].split(RegExp(r'\s+'));
    // int n0 = int.parse(parts[1]);
    ijke[i][0] = int.parse(parts[2]) - 1; // Convert to 0-based indexing
    ijke[i][1] = int.parse(parts[3]) - 1;
    prop[i][0] = double.parse(parts[4]); // E
    prop[i][1] = double.parse(parts[5]); // A
  }

  return {
    'nx': nx,
    'xyzn': xyzn,
    'mfix': mfix,
    'fnod': fnod,
    'nelx': nelx,
    'ijke': ijke,
    'prop': prop,
  };
}

Future<void> _writeResults(Map<String, Object> output) async {
  // print('(*) WRITE -----');

  final int nx = output['nx'] as int;
  final int nelx = output['nelx'] as int;
  final int ndof = output['ndof'] as int;
  final List<double> disp = output['disp'] as List<double>;
  final List<List<int>> mfix = output['mfix'] as List<List<int>>;
  final List<List<double>> prop = output['prop'] as List<List<double>>;
  final List<double> fint = output['fint'] as List<double>;
  final List<double> frea = output['frea'] as List<double>;

  final File outputFile = File('restruss.txt');
  final IOSink sink = outputFile.openWrite();
  
  // Output displacement
  sink.writeln('*displacement (n, u, v) ------');
  for (int ix = 0; ix < nx; ix++) {
    double ui = disp[ndof * ix + 0];
    double vi = disp[ndof * ix + 1];
    sink.writeln('${(ix+1).toString().padLeft(5)} ${ui.toStringAsExponential(5)} ${vi.toStringAsExponential(5)}');
  }
  sink.writeln();
  
  // Output axial force (normal force) 軸力
  sink.writeln('*axial force, stress ---------');
  for (int ie = 0; ie < nelx; ie++) {
    double stress = fint[ie] / prop[ie][1];
    sink.writeln('${(ie+1).toString().padLeft(5)} ${fint[ie].toStringAsExponential(5)} ${stress.toStringAsExponential(5)}');
  }
  sink.writeln();
  
  // Output reaction force 反力
  sink.writeln('*reaction force --------------');
  for (int ix = 0; ix < nx; ix++) {
    if (mfix[ix][0] == 1) {
      sink.writeln('${(ix+1).toString().padLeft(5)}   Rx ${frea[ndof * ix + 0].toStringAsExponential(5)}');
    }
    if (mfix[ix][1] == 1) {
      sink.writeln('${(ix+1).toString().padLeft(5)}   Ry ${frea[ndof * ix + 1].toStringAsExponential(5)}');
    }
  }
  
  await sink.close();
}

void main() async {
  final input = await _readInput();
  final output = truss2d(input);
  await _writeResults(output);
}