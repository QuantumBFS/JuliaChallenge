module problem
    integer,parameter :: num_spin=300, num_tempscales=64, nms=4000
    real,parameter :: tempscales(num_tempscales) = (/((10-i*0.15),i=0,num_tempscales-1)/) ! assign to y in increments of 1.5 starting at 1.5
    real :: jmat(num_spin,num_spin)

    !f2py integer,parameter :: num_spin,num_tempscales,nms
    !f2py timescale
    !f2py jmat

    contains
    subroutine init_problem()
        call loadexample('example.txt')
    end subroutine init_problem

    subroutine loadexample(filename)
        implicit none
        character(len=*),intent(in) :: filename
        integer :: ibond,i,j
        real :: weight
        jmat=0
        open(10, file = filename)
        do ibond = 1, num_spin*(num_spin-1)/2
            read(10, *) i,j,weight
            jmat(i+1,j+1)=weight/2
            jmat(j+1,i+1)=weight/2
        end do
        close(10)
    end subroutine loadexample

    subroutine get_cost(config,cost)
        implicit none
        real,intent(out) :: cost
        integer,intent(in) :: config(num_spin)
        !f2py integer,intent(aux) :: num_spin
        cost=sum(matmul(config,jmat)*config)
    end subroutine get_cost

    subroutine propose(config,field,ispin,delta)
        implicit none
        integer,intent(in) :: config(num_spin)
        real,intent(in) :: field(num_spin)
        integer,intent(out) :: ispin
        real,intent(out) :: delta
        real :: rn
        !f2py integer,intent(aux) :: num_spin

        call random_number(rn)
        ispin = floor(num_spin*rn)+1
        delta = -field(ispin)*config(ispin)*4 !2 for spin change, 2 for mutual energy.
    end subroutine propose

    subroutine accept(ispin,config,field)
        implicit none
        integer,intent(inout) :: config(num_spin)
        real,intent(inout) :: field(num_spin)
        integer,intent(in) :: ispin
        !f2py integer,intent(aux) :: num_spin

        config(ispin)=-config(ispin)
        !update field
        field=field+2*config(ispin)*jmat(:,ispin)
    end subroutine accept

    subroutine get_random_config(config,field)
        implicit none
        integer,intent(out) :: config(num_spin)
        real,intent(out) :: field(num_spin)
        real :: rn(num_spin)
        !f2py integer,intent(aux) :: num_spin

        call random_number(rn)
        config=floor(rn*2)*2-1
        field=matmul(jmat,config)
    end subroutine get_random_config
end module problem
