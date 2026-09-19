import sys

print("python", sys.version)
import pinocchio
import crocoddyl
import meshcat

print("pinocchio", pinocchio.__version__)
print("crocoddyl", crocoddyl.__version__)
import pydrake

print("pydrake ok")
import qsim_cpp

print("qsim_cpp", qsim_cpp)
from qsim.parser import QuasistaticParser

print("qsim parser ok")
