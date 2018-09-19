'''simulate annealing'''

from numpy import *
from abc import ABCMeta, abstractmethod
from collections import namedtuple
import pdb,time,copy

__all__=['SAP','anneal','anneal_singlerun','sap']

class SAP(object, metaclass=ABCMeta):
    '''
    Simulated Annealing Problem.
    '''

    @abstractmethod
    def get_cost(self,state):
        '''
        The cost function.

        Parameters:
            :state: state,

        Return:
            number, the cost to minimize.
        '''
        pass

    @abstractmethod
    def propose(self,state):
        '''
        Propose a move.

        Parameters:
            :state: state, the current state.

        Return:
            (info,dE), the information of the move(of state) and the energy rise.
        '''
        pass

    @abstractmethod
    def accept(self,proposal,state):
        '''
        Accept a proposal.

        Parameters:
            :proposal: tuple, the proposal (info,dE).
            :state: state,

        Return:
            state, the state after applying change.
        '''
        pass

    @abstractmethod
    def get_random_state(self):
        '''
        Get a random state, usually used as a initial state.

        Return:
            state,
        '''
        pass

def anneal_singlerun(ann,initial_state,tempscales,nms=4000):
    '''
    Perform Simulated Annealing using Metropolis updates for the single run.

    Parameters:
        :ann: <SAP>, the app.
        :initial_state: state,
        :tempscales: 1D array, the time scale from high temperature to low temperature.
        :nms: int, the number of Monte Carlo updates in each time scale.

    Return:
        (minimum cost, optimal configuration)
    '''
    state=initial_state
    opt_state=copy.deepcopy(initial_state)
    opt_cost=cost=ann.get_cost(state)
    for T in tempscales:
        uni01=random.random(nms)
        beta=1./T
        for m in range(nms):
            info,dE=ann.propose(state)
            if exp(-beta*dE)>uni01[m]:  #accept
                state=ann.accept((info,dE),state)
                cost+=dE
                if cost<opt_cost:
                    opt_cost,opt_state=cost,copy.deepcopy(state)
    return opt_cost,opt_state
 
def anneal(ann,tempscales,nrun=30,nms=4000):
    '''
    Perform Simulated Annealing with multiple runs.

    Parameters:
        :ann: <SAP>, the app.
        :tempscales: 1D array, the time scale from high temperature to low temperature.
        :nrun: int, the number of runs.
        :nms: int, the number of Monte Carlo updates in each time scale.

    Return:
        (minimum cost, optimal configuration)
    '''
    opt_cost=Inf
    for r in range(nrun):
        t0=time.time()
        initial_state=ann.get_random_state()
        cost,state=anneal_singlerun(ann,initial_state,tempscales,nms=nms)
        if cost<opt_cost:
            opt_cost=cost
            opt_state=state
        t1=time.time()
        print('%s-th run, cost=%s, Elapse -> %s'%(r,cost,t1-t0))
    return opt_cost,opt_state

'''
Flexible way to construct <SAP>.

e.g. sap(get_cost,propose,accept,get_random_state)
'''
sap=namedtuple('SAP','get_cost propose accept get_random_state')
