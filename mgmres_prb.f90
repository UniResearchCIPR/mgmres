program main
!*****************************************************************************80
!
!! MAIN is the main program for MGMRES_PRB.
!
!  Discussion:
!
!    MGMRES_PRB tests the MGMRES library.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    29 August 2012
!
!  Author:
!
!    John Burkardt
!
  implicit none

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'MGMRES_PRB:'
  write ( *, '(a)' ) '  FORTRAN90 version'
  write ( *, '(a)' ) '  Test the MGMRES library.'

  call test03 ( )
  call test04 ( )
!
!  Terminate.
!
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'MGMRES_PRB:'
  write ( *, '(a)' ) '  Normal end of execution.'
  write ( *, '(a)' ) ' '
end program

subroutine test03 ( )
!*****************************************************************************80
!
!! TEST03 tests PMGMRES_ILU_CR on the simple -1,2-1 matrix.
!
!  Discussion:
!
!    This is a very weak test, since the matrix has such a simple
!    structure, is diagonally dominant (though not strictly), 
!    and is symmetric.
!
!    To make the matrix bigger, simply increase the value of N.
!
!    Note that PGMRES_ILU_CR expects the matrix to be stored using the
!    sparse compressed row format.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    28 August 2012
!
!  Author:
!
!    John Burkardt
!
  use mgmres
  implicit none

  integer, parameter :: si = selected_int_kind (9)         ! short int
  integer, parameter :: dp = selected_real_kind (15, 307)  ! double
  integer (kind=si), parameter :: n = 20
  integer (kind=si), parameter :: nz_num = ( 3 * n - 2 )

  real    (kind=dp) a(nz_num)
  integer (kind=si) i
  integer (kind=si) ia(n+1)
  integer (kind=si) itr_max
  integer (kind=si) j
  integer (kind=si) ja(nz_num)
  integer (kind=si) k
  integer (kind=si) mr
  real    (kind=dp) rhs(n)
  integer (kind=si) test
  real    (kind=dp) tol_abs
  real    (kind=dp) tol_rel
  real    (kind=dp) x_error
  real    (kind=dp) x_estimate(n)
  real    (kind=dp) x_exact(n)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST03'
  write ( *, '(a)' ) '  Test PMGMRES_ILU_CR on the simple -1,2-1 matrix.'
!
!  Set the matrix.
!  Note that we use 1-based index values in IA and JA.
!
  k = 1
  ia(1) = 1

  write ( *, '(a)' ) ' '
  write ( *, '(a,i4,a,i4)' ) '  ia(', 1, ') = ', ia(1)

  do i = 1, n

    ia(i+1) = ia(i)

    if ( 1 < i ) then
      ia(i+1) = ia(i+1) + 1
      ja(k) = i - 1
      a(k) = -1.0D+00
      k = k + 1
    end if

    ia(i+1) = ia(i+1) + 1
    ja(k) = i
    a(k) = 2.0D+00
    k = k + 1

    if ( i < n ) then
      ia(i+1) = ia(i+1) + 1
      ja(k) = i + 1
      a(k) = -1.0D+00
      k = k + 1
    end if
    write ( *, '(a,i4,a,i4)' ) '  ia(', i + 1, ') = ', ia(i+1)
  end do
!
!  Set the right hand side:
!
  rhs(1:n-1) = 0.0D+00
  rhs(n) = real ( n + 1, kind = 8 )
!
!  Set the exact solution.
!
  do i = 1, n
    x_exact(i) = real ( i, kind = 8 )
  end do

  do test = 1, 3
!
!  Set the initial solution estimate.
!
    x_estimate(1:n) = 0.0D+00
    x_error = 0.0D+00
    do i = 1, n
      x_error = x_error + ( x_exact(i) - x_estimate(i) ) ** 2
    end do
    x_error = sqrt ( x_error )

    if ( test == 1 ) then
      itr_max = 1
      mr = 20
    else if ( test == 2 ) then
      itr_max = 2
      mr = 10
    else if ( test == 3 ) then
      itr_max = 5
      mr = 4
    end if

    tol_abs = 1.0D-08
    tol_rel = 1.0D-08

    write ( *, '(a)' ) ' '
    write ( *, '(a,i4)' ) '  Test ', test
    write ( *, '(a,i4)' ) '  Matrix order N = ', n
    write ( *, '(a,i4)' ) '  Inner iteration limit = ', mr
    write ( *, '(a,i4)' ) '  Outer iteration limit = ', itr_max
    write ( *, '(a,g14.6)' ) '  Initial X_ERROR = ', x_error

    call pmgmres_ilu_cr ( n, nz_num, ia, ja, a, x_estimate, rhs, itr_max, &
      mr, tol_abs, tol_rel )

    x_error = 0.0D+00
    do i = 1, n
      x_error = x_error + ( x_exact(i) - x_estimate(i) ) ** 2
    end do
    x_error = sqrt ( x_error )

    write ( *, '(a,g14.6)' ) '  Final X_ERROR = ', x_error

  end do

  return
end

subroutine test04 ( )
!*****************************************************************************80
!
!! TEST04 tests PMGMRES_ILU_CR on a simple 5 by 5 matrix.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    29 August 2012
!
!  Author:
!
!    John Burkardt
!
  use mgmres
  implicit none

  integer, parameter :: si = selected_int_kind (9)         ! short int
  integer, parameter :: dp = selected_real_kind (15, 307)  ! double
  integer (kind=si), parameter :: n = 5
  integer (kind=si), parameter :: nz_num = 9

  real    (kind=dp), dimension ( nz_num ) :: a = (/ &
     1.0, 2.0, 1.0, &
     2.0, &
     3.0, 3.0, &
     4.0, &
     1.0, 5.0 /)
  integer (kind=si) i
  integer (kind=si), dimension ( n + 1 ) :: ia = (/ 1, 4, 5, 7, 8, 10 /)
  integer (kind=si) itr_max
  integer (kind=si) j
  integer (kind=si), dimension ( nz_num ) :: ja = (/ &
    1, 4, 5, &
    2, &
    1, 3, &
    4, &
    2, 5 /)
  integer (kind=si) k
  integer (kind=si) mr
  real    (kind=dp), dimension ( n ) :: rhs = (/ &
    14.0, 4.0, 12.0, 16.0, 27.0 /)
  integer (kind=si) test
  real    (kind=dp) tol_abs
  real    (kind=dp) tol_rel
  real    (kind=dp) x_error
  real    (kind=dp) x_estimate(n)
  real    (kind=dp), dimension ( n ) :: x_exact = (/ 1.0, 2.0, 3.0, 4.0, 5.0 /)

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'TEST04'
  write ( *, '(a)' ) '  Test PMGMRES_ILU_CR on a simple 5 x 5 matrix.'

  write ( *, '(a)' ) ' '
  do i = 1, n
    write ( *, '(a,i2,a,i2)' ) '  ia(', i, ') = ', ia(i)
  end do
 
  do test = 1, 3
!
!  Set the initial solution estimate.
!
    x_estimate(1:n) = 0.0D+00
    x_error = 0.0D+00
    do i = 1, n
      x_error = x_error + ( x_exact(i) - x_estimate(i) ) ** 2
    end do
    x_error = sqrt ( x_error )

    if ( test == 1 ) then
      itr_max = 1
      mr = 20
    else if ( test == 2 ) then
      itr_max = 2
      mr = 10
    else if ( test == 3 ) then
      itr_max = 5
      mr = 4
    end if

    tol_abs = 1.0D-08
    tol_rel = 1.0D-08

    write ( *, '(a)' ) ' '
    write ( *, '(a,i4)' ) '  Test ', test
    write ( *, '(a,i4)' ) '  Matrix order N = ', n
    write ( *, '(a,i4)' ) '  Inner iteration limit = ', mr
    write ( *, '(a,i4)' ) '  Outer iteration limit = ', itr_max
    write ( *, '(a,g14.6)' ) '  Initial X_ERROR = ', x_error

    call pmgmres_ilu_cr ( n, nz_num, ia, ja, a, x_estimate, rhs, itr_max, &
      mr, tol_abs, tol_rel )

    x_error = 0.0D+00
    do i = 1, n
      x_error = x_error + ( x_exact(i) - x_estimate(i) ) ** 2
    end do
    x_error = sqrt ( x_error )

    write ( *, '(a,g14.6)' ) '  Final X_ERROR = ', x_error

  end do

  return
end
