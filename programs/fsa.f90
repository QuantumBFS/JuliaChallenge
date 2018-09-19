! initialize a random seed from the system clock at every run (fortran 95 code)
subroutine init_random_seed()
    INTEGER :: i, n, clock
    INTEGER, DIMENSION(:), ALLOCATABLE :: seed

    CALL RANDOM_SEED(size = n)
    ALLOCATE(seed(n))
    CALL SYSTEM_CLOCK(COUNT=clock)
    seed = clock + 37 * (/ (i - 1, i = 1, n) /)
    CALL RANDOM_SEED(PUT = seed)
    DEALLOCATE(seed)
end subroutine init_random_seed

!Perform Simulated Annealing using Metropolis updates for the single run.
!
!Parameters:
!    :ann: <SAP>, the app.
!    :initial_config: config,
!    :tempscales: 1D array, the time scale from high temperature to low temperature.
!
!Return:
!    (minimum cost, optimal configuration)
subroutine anneal_singlerun(config,field,opt_cost,opt_config)
    use problem
    implicit none
    integer,intent(inout) :: config(num_spin)
    real,intent(inout) :: field(num_spin)
    integer :: it,ispin,m
    real :: cost,delta
    real :: uni01(nms),beta
    integer,intent(out) :: opt_config(num_spin)
    real,intent(out) :: opt_cost

    opt_config=config
    call get_cost(config,cost)
    opt_cost=cost

    do it=1,num_tempscales
        beta=1/tempscales(it)
        call random_number(uni01)
        do m=1,nms
            call propose(config,field,ispin,delta)
            if(exp(-beta*delta)>uni01(m)) then  !accept
                call accept(ispin,config,field)
                cost=cost+delta
                if(cost<opt_cost) then
                    opt_cost=cost
                    opt_config=config
                endif
            endif
        enddo
    enddo
end subroutine anneal_singlerun
 
!Perform Simulated Annealing with multiple runs.
subroutine anneal(nrun)
    use problem
    implicit none
    integer,intent(in) :: nrun
    real :: cost,opt_cost
    integer :: config(num_spin),opt_config(num_spin)
    integer :: initial_config(num_spin)
    real :: initial_field(num_spin)
    integer :: r

    opt_cost=999999
    do r=1,nrun
        call get_random_config(initial_config,initial_field)
        call anneal_singlerun(initial_config,initial_field,cost,config)
        if(cost<opt_cost) then
            opt_cost=cost
            opt_config=config
        endif
        print*,r,'-th run, cost=',cost
    enddo
end subroutine anneal

subroutine test()
    use problem
    call init_problem()
    call init_random_seed()
    call anneal(30)
end subroutine test
