import 'dart:io';
import 'dart:math';

/// 「dart run fem2d.dart」で実行

Map<String, Object> fem2d(Map<String, Object> input) {
  // Data structures
  List<List<int>> ijke = [];      // Element connectivity
  List<List<int>> mfix = [];      // Boundary conditions
  List<int> mdof = [];            // DOF table
  List<List<double>> xyzn = [];   // Nodal coordinates
  List<List<double>> prop = [];   // Material properties
  List<List<double>> dnod = [];   // Enforced displacement
  List<List<double>> fnod = [];   // Nodal forces
  List<List<double>> body = [];   // Body forces
  List<List<List<double>>> vske = []; // Element stiffness
  List<double> fext = [];         // External force vector
  List<double> disp = [];         // Displacement vector
  List<double> diag = [];         // Diagonal for CGM
  List<double> cgw1 = [];         // CGM work array 1
  List<double> cgw2 = [];         // CGM work array 2
  List<double> cgw3 = [];         // CGM work array 3
  List<List<double>> strs = [];   // Stress components
  List<List<double>> strn = [];   // Strain components
  
  int nx = 0;      // Number of nodes
  int nelx = 0;    // Number of elements
  int nd = 2;      // Degrees of freedom per node
  int neq = 0;     // Total equations
  int n2d = 1;     // 1: plane stress, 2: plane strain
  double he = 1.0; // Thickness


  nx = input['nx'] as int;
  xyzn = input['xyzn'] as List<List<double>>; 
  mfix = input['mfix'] as List<List<int>>; 
  dnod = input['dnod'] as List<List<double>>; 
  fnod = input['fnod'] as List<List<double>>; 
  nelx = input['nelx'] as int; 
  ijke = input['ijke'] as List<List<int>>; 
  prop = input['prop'] as List<List<double>>; 
  body = input['body'] as List<List<double>>; 

  neq = nx * nd;
  
  // Allocate arrays
  mdof = List.filled(neq, 0);
  fext = List.filled(neq, 0.0);
  disp = List.filled(neq, 0.0);
  diag = List.filled(neq, 0.0);
  cgw1 = List.filled(neq, 0.0);
  cgw2 = List.filled(neq, 0.0);
  cgw3 = List.filled(neq, 0.0);
  vske = List.generate(nelx, (_) => 
          List.generate(8, (_) => List.filled(8, 0.0)));
  strs = List.generate(nelx, (_) => List.filled(9, 0.0));
  strn = List.generate(nelx, (_) => List.filled(9, 0.0));
  

  void setupDOF() {
    // print('\n(*) DOFTAB -----');
    
    // Initialize DOF table
    mdof.fillRange(0, neq, 1);
    disp.fillRange(0, neq, 0.0);
    
    for (int ix = 0; ix < nx; ix++) {
      if (mfix[ix][0] == 1) {
        mdof[nd * ix + 0] = 0;
        disp[nd * ix + 0] = dnod[ix][0];
      }
      if (mfix[ix][1] == 1) {
        mdof[nd * ix + 1] = 0;
        disp[nd * ix + 1] = dnod[ix][1];
      }
    }
    
    // Setup nodal forces
    fext.fillRange(0, neq, 0.0);
    for (int ix = 0; ix < nx; ix++) {
      fext[nd * ix + 0] = fnod[ix][0];
      fext[nd * ix + 1] = fnod[ix][1];
    }
  }

  void assembleStiffness() {
    // print('\n(*) ELEMENT -----');
    void assembleTRIA3(int ie, List<List<double>> cc) {
      // Get nodal coordinates
      double x1 = xyzn[ijke[ie][0] - 1][0];
      double y1 = xyzn[ijke[ie][0] - 1][1];
      double x2 = xyzn[ijke[ie][1] - 1][0];
      double y2 = xyzn[ijke[ie][1] - 1][1];
      double x3 = xyzn[ijke[ie][2] - 1][0];
      double y3 = xyzn[ijke[ie][2] - 1][1];
      
      // Calculate area
      double ae = (x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2.0;
      if (ae < 0.0) throw Exception('Ae < 0: clockwise!');
      
      // B matrix
      final bb = List.generate(3, (_) => List.filled(8, 0.0));
      bb[0][0] = (y2 - y3) / ae / 2.0;
      bb[0][2] = (y3 - y1) / ae / 2.0;
      bb[0][4] = (y1 - y2) / ae / 2.0;
      bb[1][1] = (x3 - x2) / ae / 2.0;
      bb[1][3] = (x1 - x3) / ae / 2.0;
      bb[1][5] = (x2 - x1) / ae / 2.0;
      bb[2][0] = bb[1][1];
      bb[2][1] = bb[0][0];
      bb[2][2] = bb[1][3];
      bb[2][3] = bb[0][2];
      bb[2][4] = bb[1][5];
      bb[2][5] = bb[0][4];
      
      // Stiffness matrix
      for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
          for (int k = 0; k < 3; k++) {
            for (int l = 0; l < 3; l++) {
              vske[ie][i][j] += bb[k][i] * cc[k][l] * bb[l][j] * ae * he;
            }
          }
        }
      }
      
      // Body force
      for (int jn = 0; jn < 3; jn++) {
        for (int kd = 0; kd < nd; kd++) {
          int ln = nd * (ijke[ie][jn] - 1) + kd;
          fext[ln] += body[ie][kd] * ae * he / 3.0;
        }
      }
    }

    void assembleQUAD4(int ie, List<List<double>> cc, 
                      List<double> gl, List<double> wl) {
      for (int ly = 0; ly < 2; ly++) {
        for (int lx = 0; lx < 2; lx++) {
          double gx = gl[lx];
          double gy = gl[ly];
          double wx = wl[lx];
          double wy = wl[ly];
          
          // Shape function derivatives
          final dNdg = List.generate(4, (_) => List.filled(2, 0.0));
          dNdg[0][0] = 0.25 * (gy - 1.0);
          dNdg[0][1] = 0.25 * (gx - 1.0);
          dNdg[1][0] = 0.25 * (-gy + 1.0);
          dNdg[1][1] = 0.25 * (-gx - 1.0);
          dNdg[2][0] = 0.25 * (gy + 1.0);
          dNdg[2][1] = 0.25 * (gx + 1.0);
          dNdg[3][0] = 0.25 * (-gy - 1.0);
          dNdg[3][1] = 0.25 * (-gx + 1.0);
          
          // Jacobian
          final dxdg = List.generate(2, (_) => List.filled(2, 0.0));
          for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
              for (int k = 0; k < 4; k++) {
                dxdg[i][j] += xyzn[ijke[ie][k] - 1][i] * dNdg[k][j];
              }
            }
          }
          
          double dJ = dxdg[0][0] * dxdg[1][1] - dxdg[0][1] * dxdg[1][0];
          if (dJ < 0.0) throw Exception('dJ < 0: clockwise!');
          
          // Inverse Jacobian
          final dgdx = List.generate(2, (_) => List.filled(2, 0.0));
          dgdx[0][0] = dxdg[1][1] / dJ;
          dgdx[0][1] = -dxdg[0][1] / dJ;
          dgdx[1][0] = -dxdg[1][0] / dJ;
          dgdx[1][1] = dxdg[0][0] / dJ;
          
          // Derivatives in physical coordinates
          final dNdx = List.generate(4, (_) => List.filled(2, 0.0));
          for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 2; j++) {
              for (int k = 0; k < 2; k++) {
                dNdx[i][j] += dNdg[i][k] * dgdx[k][j];
              }
            }
          }
          
          // B matrix
          final bb = List.generate(3, (_) => List.filled(8, 0.0));
          for (int i = 0; i < 4; i++) {
            bb[0][2 * i] = dNdx[i][0];
            bb[1][2 * i + 1] = dNdx[i][1];
            bb[2][2 * i] = dNdx[i][1];
            bb[2][2 * i + 1] = dNdx[i][0];
          }
          
          // Add to stiffness matrix
          double dw = he * dJ * wx * wy;
          for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 8; j++) {
              for (int k = 0; k < 3; k++) {
                for (int l = 0; l < 3; l++) {
                  vske[ie][i][j] += bb[k][i] * cc[k][l] * bb[l][j] * dw;
                }
              }
            }
          }
          
          // Body force
          final sh = [
            0.25 * (1.0 - gx) * (1.0 - gy),
            0.25 * (1.0 + gx) * (1.0 - gy),
            0.25 * (1.0 + gx) * (1.0 + gy),
            0.25 * (1.0 - gx) * (1.0 + gy)
          ];
          
          for (int jn = 0; jn < 4; jn++) {
            for (int kd = 0; kd < nd; kd++) {
              int ln = nd * (ijke[ie][jn] - 1) + kd;
              fext[ln] += sh[jn] * body[ie][kd] * dw;
            }
          }
        }
      }
    }
    
    // Gaussian integration points
    final gl = [-1.0 / sqrt(3.0), 1.0 / sqrt(3.0)];
    final wl = [1.0, 1.0];
    
    for (int ie = 0; ie < nelx; ie++) {
      int node = ijke[ie][4];
      double yng = prop[ie][0];
      double poi = prop[ie][1];
      // print('${ie + 1} $node');
      
      // Constitutive matrix
      final cc = List.generate(3, (_) => List.filled(3, 0.0));
      if (n2d == 1) { // Plane stress
        double factor = yng / (1.0 - poi * poi);
        cc[0][0] = factor;
        cc[1][1] = factor;
        cc[0][1] = factor * poi;
        cc[1][0] = factor * poi;
        cc[2][2] = factor * (1.0 - poi) / 2.0;
      } else { // Plane strain
        double denom = (1.0 + poi) * (1.0 - 2.0 * poi);
        cc[0][0] = yng * (1.0 - poi) / denom;
        cc[1][1] = yng * (1.0 - poi) / denom;
        cc[0][1] = yng * poi / denom;
        cc[1][0] = yng * poi / denom;
        cc[2][2] = yng / (2.0 * (1.0 + poi));
      }
      
      if (node == 3) {
        // TRIA3 element
        assembleTRIA3(ie, cc);
      } else {
        // QUAD4 element
        assembleQUAD4(ie, cc, gl, wl);
      }
    }
  }  

  void solve() {
    // print('\n(*) SOLVER -----');
    void matrixVector(List<double> result, List<double> vec) {
      for (int ie = 0; ie < nelx; ie++) {
        int node = ijke[ie][4];
        for (int io = 0; io < node; io++) {
          int ic = ijke[ie][io] - 1;
          for (int id = 0; id < nd; id++) {
            int ii = nd * io + id;
            int ig = nd * ic + id;
            double di = diag[ig];
            
            if (mdof[ig] >= 1) {
              for (int ko = 0; ko < node; ko++) {
                int kc = ijke[ie][ko] - 1;
                for (int kd = 0; kd < nd; kd++) {
                  int kk = nd * ko + kd;
                  int kg = nd * kc + kd;
                  double dk = diag[kg];
                  result[ig] += di * dk * vske[ie][ii][kk] * vec[kg];
                }
              }
            }
          }
        }
      }
    }

    double dotProduct(List<double> a, List<double> b) {
      double sum = 0.0;
      for (int i = 0; i < a.length; i++) {
        sum += a[i] * b[i];
      }
      return sum;
    }
    
    // Diagonal scaling
    diag.fillRange(0, neq, 0.0);
    for (int ie = 0; ie < nelx; ie++) {
      int node = ijke[ie][4];
      for (int io = 0; io < node; io++) {
        int ic = ijke[ie][io] - 1;
        for (int id = 0; id < nd; id++) {
          int ii = nd * io + id;
          int ig = nd * ic + id;
          diag[ig] += vske[ie][ii][ii];
        }
      }
    }
    
    for (int i = 0; i < neq; i++) {
      double dv = diag[i].abs();
      if (dv > 1.0e-9) {
        diag[i] = 1.0 / sqrt(dv);
      } else {
        diag[i] = 1.0;
      }
    }
    
    for (int i = 0; i < neq; i++) {
      disp[i] /= diag[i];
    }
    
    // Initial residual
    cgw1.fillRange(0, neq, 0.0);
    for (int i = 0; i < neq; i++) {
      if (mdof[i] >= 1) {
        cgw1[i] = fext[i] * diag[i];
      }
    }
    
    cgw3.fillRange(0, neq, 0.0);
    matrixVector(cgw3, disp);
    
    for (int i = 0; i < neq; i++) {
      cgw1[i] -= cgw3[i];
    }
    
    for (int i = 0; i < neq; i++) {
      cgw2[i] = cgw1[i];
    }
    
    double r0r0 = dotProduct(cgw1, cgw1);
    
    // Conjugate gradient iteration
    for (int kcg = 0; kcg < neq * 10; kcg++) {
      cgw3.fillRange(0, neq, 0.0);
      matrixVector(cgw3, cgw2);
      
      double app = dotProduct(cgw3, cgw2);
      double rr = dotProduct(cgw1, cgw1);
      double alph = rr / app;
      
      for (int i = 0; i < neq; i++) {
        disp[i] += alph * cgw2[i];
        cgw1[i] -= alph * cgw3[i];
      }
      
      double r1r1 = dotProduct(cgw1, cgw1);
      if (r1r1 < 1.0e-99) r1r1 = 1.0e-9;
      
      // print('${kcg + 1}) ${sqrt(r_r / r0_r0).toStringAsExponential(5)} '
      //       '${r1_r1.toStringAsExponential(5)}');
      
      if (sqrt(rr / r0r0) < 1.0e-12) {
        for (int i = 0; i < neq; i++) {
          disp[i] *= diag[i];
        }
        break;
      }
      
      double beta = r1r1 / rr;
      for (int i = 0; i < neq; i++) {
        cgw2[i] = cgw1[i] + beta * cgw2[i];
      }
    }
  }

  void postProcess() {
    // print('\n(*) POSTPR -----');
    
    // Zero small values
    for (int i = 0; i < neq; i++) {
      if (disp[i].abs() < 1.0e-12) disp[i] = 0.0;
    }
    
    // Calculate strain and stress for each element
    for (int ie = 0; ie < nelx; ie++) {
      int node = ijke[ie][4];
      double yng = prop[ie][0];
      double poi = prop[ie][1];
      
      // Get element displacements
      List<double> u = List.filled(4, 0.0);
      List<double> v = List.filled(4, 0.0);
      for (int i = 0; i < node; i++) {
        u[i] = disp[nd * (ijke[ie][i] - 1) + 0];
        v[i] = disp[nd * (ijke[ie][i] - 1) + 1];
      }
      
      double exx, eyy, exy, eyx;
      
      if (node == 3) {
        // TRIA3 strain calculation
        double x1 = xyzn[ijke[ie][0] - 1][0];
        double y1 = xyzn[ijke[ie][0] - 1][1];
        double x2 = xyzn[ijke[ie][1] - 1][0];
        double y2 = xyzn[ijke[ie][1] - 1][1];
        double x3 = xyzn[ijke[ie][2] - 1][0];
        double y3 = xyzn[ijke[ie][2] - 1][1];
        double at = (x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2.0;
        
        double b11 = (y2 - y3) / at / 2.0;
        double b13 = (y3 - y1) / at / 2.0;
        double b15 = (y1 - y2) / at / 2.0;
        double b22 = (x3 - x2) / at / 2.0;
        double b24 = (x1 - x3) / at / 2.0;
        double b26 = (x2 - x1) / at / 2.0;
        
        exx = b11 * u[0] + b13 * u[1] + b15 * u[2];
        eyy = b22 * v[0] + b24 * v[1] + b26 * v[2];
        exy = b22 * u[0] + b24 * u[1] + b26 * u[2];
        eyx = b11 * v[0] + b13 * v[1] + b15 * v[2];
      } else {
        // QUAD4 strain calculation (at center)
        double x1 = xyzn[ijke[ie][0] - 1][0];
        double y1 = xyzn[ijke[ie][0] - 1][1];
        double x2 = xyzn[ijke[ie][1] - 1][0];
        double y2 = xyzn[ijke[ie][1] - 1][1];
        double x3 = xyzn[ijke[ie][2] - 1][0];
        double y3 = xyzn[ijke[ie][2] - 1][1];
        double x4 = xyzn[ijke[ie][3] - 1][0];
        double y4 = xyzn[ijke[ie][3] - 1][1];
        
        double g11 = -0.25, g12 = -0.25;
        double g21 = 0.25, g22 = -0.25;
        double g31 = 0.25, g32 = 0.25;
        double g41 = -0.25, g42 = 0.25;
        
        double f11 = x1 * g11 + x2 * g21 + x3 * g31 + x4 * g41;
        double f12 = x1 * g12 + x2 * g22 + x3 * g32 + x4 * g42;
        double f21 = y1 * g11 + y2 * g21 + y3 * g31 + y4 * g41;
        double f22 = y1 * g12 + y2 * g22 + y3 * g32 + y4 * g42;
        double det = f11 * f22 - f12 * f21;
        
        double h11 = f22 / det, h12 = -f12 / det;
        double h21 = -f21 / det, h22 = f11 / det;
        
        double b11 = g11 * h11 + g12 * h21;
        double b12 = g11 * h12 + g12 * h22;
        double b21 = g21 * h11 + g22 * h21;
        double b22 = g21 * h12 + g22 * h22;
        double b31 = g31 * h11 + g32 * h21;
        double b32 = g31 * h12 + g32 * h22;
        double b41 = g41 * h11 + g42 * h21;
        double b42 = g41 * h12 + g42 * h22;
        
        exx = b11 * u[0] + b21 * u[1] + b31 * u[2] + b41 * u[3];
        eyy = b12 * v[0] + b22 * v[1] + b32 * v[2] + b42 * v[3];
        exy = b12 * u[0] + b22 * u[1] + b32 * u[2] + b42 * u[3];
        eyx = b11 * v[0] + b21 * v[1] + b31 * v[2] + b41 * v[3];
      }
      
      // Constitutive relation
      double c11, c22, c12, c21, c33;
      if (n2d == 1) { // Plane stress
        double factor = yng / (1.0 - poi * poi);
        c11 = factor;
        c22 = factor;
        c12 = factor * poi;
        c21 = factor * poi;
        c33 = factor * (1.0 - poi) / 2.0;
      } else { // Plane strain
        double denom = (1.0 + poi) * (1.0 - 2.0 * poi);
        c11 = yng * (1.0 - poi) / denom;
        c22 = yng * (1.0 - poi) / denom;
        c12 = yng * poi / denom;
        c21 = yng * poi / denom;
        c33 = yng / (2.0 * (1.0 + poi));
      }
      
      // Stress components
      double sxx = c11 * exx + c12 * eyy;
      double syy = c21 * exx + c22 * eyy;
      double sxy = c33 * exy + c33 * eyx;
      
      // Out-of-plane components
      double szz, ezz;
      if (n2d == 1) {
        szz = 0.0;
        ezz = -poi / yng * (sxx + syy);
      } else {
        szz = poi * yng / (1.0 + poi) / (1.0 - 2.0 * poi) * (exx + eyy);
        ezz = 0.0;
      }
      
      // Principal stresses
      double s1 = 0.5 * (sxx + syy);
      double s2 = 0.5 * (sxx - syy);
      double s3 = sqrt(s2 * s2 + sxy * sxy);
      double sp1 = s1 + s3;
      double sp2 = s1 - s3;
      
      // von Mises stress
      double s0 = (sxx + syy + szz) / 3.0;
      double s11 = sxx - s0;
      double s22 = syy - s0;
      double s33 = szz - s0;
      double s12 = sxy;
      double s21 = sxy;
      double sI2 = s11 * s11 + s22 * s22 + s33 * s33 + 
                   s12 * s12 + s21 * s21;
      double von = sqrt(1.5 * sI2);
      
      // Save results
      strn[ie][0] = exx;
      strn[ie][1] = eyy;
      strn[ie][2] = exy + eyx;
      strn[ie][3] = ezz;
      
      strs[ie][0] = sxx;
      strs[ie][1] = syy;
      strs[ie][2] = sxy;
      strs[ie][3] = szz;
      strs[ie][4] = sp1;
      strs[ie][5] = sp2;
      strs[ie][6] = von;
      
      // Zero small values
      for (int j = 0; j < 9; j++) {
        if (strs[ie][j].abs() < 1.0e-12) strs[ie][j] = 0.0;
        if (strn[ie][j].abs() < 1.0e-12) strn[ie][j] = 0.0;
      }
    }
  }


  setupDOF();
  assembleStiffness();
  solve();
  postProcess();  

  return {
    'nx': nx,
    'nd': nd,
    'disp': disp,
    'nelx': nelx,
    'ijke': ijke,
    'strs': strs,
    'strn': strn,
  };
}

Future<Map<String, Object>> _readInput() async {
  // print('\n(*) READ -----');
  
  final file = File('inpfem2d.txt');
  final lines = await file.readAsLines();
  int lineIdx = 0;

  // Skip NODE header
  lineIdx++;
  
  // Read number of nodes
  final nx = int.parse(lines[lineIdx++].substring(0,7));
  
  // Initialize node arrays
  final xyzn = List.generate(nx, (_) => List.filled(2, 0.0));
  final mfix = List.generate(nx, (_) => List.filled(2, 0));
  final dnod = List.generate(nx, (_) => List.filled(2, 0.0));
  final fnod = List.generate(nx, (_) => List.filled(2, 0.0));
  
  // Read node data
  for (int i = 0; i < nx; i++) {
    final parts = lines[lineIdx++].trim().split(RegExp(r'\s+'));
    int idx = 1;
    xyzn[i][0] = double.parse(parts[idx++]);
    xyzn[i][1] = double.parse(parts[idx++]);
    mfix[i][0] = int.parse(parts[idx++]);
    mfix[i][1] = int.parse(parts[idx++]);
    dnod[i][0] = double.parse(parts[idx++]);
    dnod[i][1] = double.parse(parts[idx++]);
    fnod[i][0] = double.parse(parts[idx++]);
    fnod[i][1] = double.parse(parts[idx++]);
  }
  
  // Skip ELEMENT header
  lineIdx++;
  
  // Read number of elements
  final nelx = int.parse(lines[lineIdx++].substring(0,7));
  
  // Initialize element arrays
  final ijke = List.generate(nelx, (_) => List.filled(5, 0));
  final prop = List.generate(nelx, (_) => List.filled(2, 0.0));
  final body = List.generate(nelx, (_) => List.filled(2, 0.0));
  
  // Read element data
  for (int i = 0; i < nelx; i++) {
    final parts = lines[lineIdx++].trim().split(RegExp(r'\s+'));
    int idx = 1;
    ijke[i][4] = int.parse(parts[idx++]); // node count
    ijke[i][0] = int.parse(parts[idx++]);
    ijke[i][1] = int.parse(parts[idx++]);
    ijke[i][2] = int.parse(parts[idx++]);
    ijke[i][3] = int.parse(parts[idx++]);
    prop[i][0] = double.parse(parts[idx++]); // Young's modulus
    prop[i][1] = double.parse(parts[idx++]); // Poisson's ratio
    body[i][0] = double.parse(parts[idx++]);
    body[i][1] = double.parse(parts[idx++]);
  }
  
  return {
    'nx': nx,
    'xyzn': xyzn,
    'mfix': mfix,
    'dnod': dnod,
    'fnod': fnod,
    'nelx': nelx,
    'ijke': ijke,
    'prop': prop,
    'body': body,
  };
}

Future<void> _writeOutput(Map<String, Object> output) async {
  // print('\n(*) WRITE -----');

  final nx = output['nx'] as int;
  final nd = output['nd'] as int;
  final disp = output['disp'] as List<double>;
  final nelx = output['nelx'] as int;
  final ijke = output['ijke'] as List<List<int>>;
  final strs = output['strs'] as List<List<double>>;
  final strn = output['strn'] as List<List<double>>;
  
  final outputFile = File('resfem2d.txt');
  final sink = outputFile.openWrite();
  
  // Write displacements
  sink.writeln('*displacement (node, u, v) ---');
  for (int ix = 0; ix < nx; ix++) {
    double ui = disp[nd * ix + 0];
    double vi = disp[nd * ix + 1];
    sink.writeln('${(ix + 1).toString().padLeft(5)} '
                  '${ui.toStringAsExponential(5).padLeft(13)} '
                  '${vi.toStringAsExponential(5).padLeft(13)}');
  }
  sink.writeln();
  
  // Write stress components
  sink.writeln('*Stress (e, t/q, sxx, syy, sxy, szz) ---');
  for (int ie = 0; ie < nelx; ie++) {
    sink.write('${(ie + 1).toString().padLeft(5)} '
                '${ijke[ie][4].toString().padLeft(3)}');
    for (int j = 0; j < 4; j++) {
      sink.write(' ${strs[ie][j].toStringAsExponential(5).padLeft(13)}');
    }
    sink.writeln();
  }
  sink.writeln();
  
  // Write principal stresses
  sink.writeln('*Stress (e, t/q, sp1, sp2, von) --------');
  for (int ie = 0; ie < nelx; ie++) {
    sink.write('${(ie + 1).toString().padLeft(5)} '
                '${ijke[ie][4].toString().padLeft(3)}');
    for (int j = 4; j < 7; j++) {
      sink.write(' ${strs[ie][j].toStringAsExponential(5).padLeft(13)}');
    }
    sink.writeln();
  }
  sink.writeln();
  
  // Write strain components
  sink.writeln('*Strain (e, t/q, exx, eyy, gxy, ezz) --------');
  for (int ie = 0; ie < nelx; ie++) {
    sink.write('${(ie + 1).toString().padLeft(5)} '
                '${ijke[ie][4].toString().padLeft(3)}');
    for (int j = 0; j < 4; j++) {
      sink.write(' ${strn[ie][j].toStringAsExponential(5).padLeft(13)}');
    }
    sink.writeln();
  }
  sink.writeln();
  
  sink.close();
}

void main() async {
  final input = await _readInput();
  final output = fem2d(input);
  await _writeOutput(output);
}