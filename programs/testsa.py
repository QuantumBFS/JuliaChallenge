'''
Tests for nrg.
'''
from numpy import *
from numpy.testing import dec,assert_,assert_raises,assert_almost_equal,assert_allclose
from scipy.sparse import coo_matrix
import pdb,sys

from sa import SAP,anneal

class CC(SAP):
    def __init__(self,J):
        self.J=J

    def get_cost(self,state):
        config=state[0]
        return (self.J*config[:,newaxis]*config).sum()

    def propose(self,state):
        config,field=state
        N=len(self.J)
        i = random.randint(N)
        dE=-field[i]*config[i]*4 #2 for spin change, 2 for mutual energy.
        return i,dE

    def accept(self,proposal,state):
        i,dE=proposal
        config,field=state
        config[i]*=-1
        #update field
        ci=config[i]
        field+=(2*ci)*self.J[:,i]
        return (config,field)

    def get_random_state(self):
        config=sign(random.random(len(self.J))-0.5)
        field=self.J.dot(config)
        return (config,field)

def test_codec():
    #run a simple test: code challenge
    N=300
    data=loadtxt('example.txt')
    J=coo_matrix((data[:,2],(data[:,0],data[:,1])),shape=(N,N),dtype='int32').toarray()
    J=(J+J.T)/2.
    cc=CC(J)
    Emin,Config=anneal(cc,tempscales=linspace(10,0.6,51),nms=4000,nrun=30)
    assert_(Emin==-3858 and cc.get_cost(Config)==Emin)

if __name__=='__main__':
    test_codec()
