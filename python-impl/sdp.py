import numpy as np
from cvxopt import matrix, solvers
import time
def sdp(X,y,z,gamma):
    time1 = time.time()
    (m,n) = X.shape
    Y = np.concatenate([X, np.ones((m,1))], axis = 1)
    A11 = np.dot(Y.T, Y) #4*4
    A11 = (A11.T+A11)/2 #4*4
    A13 = np.dot(-Y.T, y).reshape(-1,1) #4*1
    A12 = np.dot(Y.T, z-y).reshape(-1,1) #4*1
    A22 = np.array([np.linalg.norm(z-y)**2]).reshape(1,1) #1*1
    A23 = -1*np.array([np.dot((z-y).T, y)]).reshape(1,1) #1*1
    A33 = np.dot(y.T, y) #1*1
    A1 = np.concatenate([A11, A12, A13], axis = 1)
    A2 = np.concatenate([A12.T, A22, A23], axis = 1)
    A3 = np.concatenate([A13.T, A23, A33], axis = 1)
    A = np.concatenate([A1, A2, A3], axis = 0)
   
    B = np.zeros((n+3, n+3))
    for i in range(n+1, n+3):
        for j in range(n+1, n+3):
            B[i][j]=1
    C = np.zeros((n+3, n+3))
    temp = np.identity(n+1)
    for i in range(n+1):
        for j in range(n+1):
            C[i][j]=1/gamma*temp[i][j]
    for i in range(n+1, n+3):
        for j in range(n+1, n+3):
            C[i][j]=-0.5
    B = B.reshape(1,-1)
    C = -1 * C.reshape(1,-1)
   
    h = [matrix(A.tolist())]
    c = matrix([1.,0.])
    sol = solvers.sdp(c, Gs=[matrix([B.tolist()[0], C.tolist()[0]])], hs=h)
    time2 = time.time()
    return time2-time1
    
    
    
    
    


