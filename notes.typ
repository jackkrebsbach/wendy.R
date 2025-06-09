#import "@preview/unequivocal-ams:0.1.2": ams-article, theorem, proof
#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#show heading: set block(above: 1.4em, below: 1em)
#set math.equation(numbering: "(1)")

#show math.equation: it => {
  if it.block and not it.has("label") [
    #counter(math.equation).update(v => calc.max(v - 1, 0))
    #math.equation(it.body, block: true, numbering: none)#label("")
  ] else {
    it
  }  
}

#let udot = {$accent(bold(u),dot)$}

#show: ams-article.with(
  title: [WENDy for Nonlinear ODE],
  authors: (
    (
      name: "Jack Krebsbach",
    ),
  ),
)


#set page(margin: 2cm)

#set text(font: "New Computer Modern", size: 12pt)

= Strong Form <strongformsection>

Given observed data, we wish to estimate the parameters of a $D$-dimensional system of ordinary differential equations (ODE). This system is assumed to have the form


$ udot = bold(f)(bold(p), bold(u)(t),t) $<strongform>


where $ bold(u)(t) in cal(H)^1((0,T), RR^D),  space bold(f)(bold(p), bold(u)(t), t) = vec(f_(1)(bold(p), bold(u)(t), t), f_2(bold(p), bold(u)(t), t), dots.v, f_(D)(bold(p), bold(u)(t), t))  in RR^D space #footnote[$cal(H)$ is a Sobelev Space] $

Note that $bold(u)(t)$ is the function state variable at time $t in [0,T]$. The system maybe be Nonlinear in Parameters (NiP).

 There are a finite number of parameters $bold(p) in RR^J$ which parameterize $bold(f)$. Bold lowercase letters represent vectors while bold uppercase letters represent matrices.




#pagebreak()
= Weak Form  <weakformsection>

To convert from the strong form, @strongform, to the weak from, we first multiply the right and left sides of the equality element wise  with a test function $bold(phi)_(k)(t) = bold(1)_D  phi_(k)(t)$ where $phi_(k)(t) in cal(C)_C^(infinity)((0,T), RR)$ and then integrate over the domain $udot$ and $bold(f)$, i.e,   


$ integral_0^T bold(phi)_(k)(t) dot.circle udot dif t = integral_0^T bold(phi)_(k)(t) dot.circle bold(f) dif t #footnote[ $dot.circle$ is the Hadamard product (element wise multiplication of two vectors)] $<weakform> 


Using integration by parts of the lefthand side (LHS) the strong form, @strongform, becomes  


$ underbrace(cancel(bold(phi)(t) dot.circle bold(u)(t) ), bold(0)) space stretch(|,size: #150%)_(0)^(T)  -integral_0^T accent(bold(phi),dot)_(k)(t) dot.circle  bold(u)(t) dif t = integral_0^T bold(phi)_(k)(t) dot.circle bold(f) dif t $<weakform2>

where  the derivative is transfered to the test function. Now the data (state) match the form of the equality. Thus, for a given test function $bold(phi)(k)(t)$, the weak form of @strongform is:


$ -integral_0^T vec(
  accent(phi,dot)_(k)(t) u_1(t),
  accent(phi,dot)_(k)(t) u_2(t),
  dots.v,
  accent(phi,dot)_(k)(t) u_(D)(t)
) dif t =  integral_0^T vec(
  phi_(k)(t) f_1(bold(p), bold(u)(t), t),
  phi_(k)(t) f_2(bold(p), bold(u)(t), t),
  dots.v,
  phi_(k)(t) f_(D)(bold(p), bold(u)(t), t)
) dif t $ 


Where equality holds for each dimension of the system. Formally, in order for $bold(u)(t)$ to be a solution to the weak form of the ODE, it must hold for all possible test functions. In practice, we consider a finite number of test functions. See @interpretationsection for further interpretation.

#pagebreak()
= Discretization <discretizationsection>


We assume that there are $M$ observed state data composed of the true and noise.They are equispaced along the domain $(0,T)$ and take the form

$ bold(u)_m = bold(u)(t_m) + bold(epsilon)_m space forall m in {0, dots ,M}  $


where $bold(epsilon)_m attach(~, t:"i.i.d") bold(cal(N))(bold(0), bold(Sigma)).$

To satisfy @weakform2 for the set of $K$ test functions we build the following matrices:



$
bold(Phi) = 
mat(
  phi_1(t_0), phi_1(t_1), dots, phi_1(t_M);
  phi_2(t_0), phi_1(t_1), dots, phi_2(t_M);
  dots.v, , dots.down ,;
  phi_(K)(t_0),phi_(K)(t_1), dots, phi_(K)(t_M)
)
in RR^(K times (M+1))
,

accent(bold(Phi),dot) =
mat(
  accent(phi,dot)_1(t_0), accent(phi,dot)_1(t_1), dots, accent(phi,dot)_1(t_M);
  accent(phi,dot)_2(t_0), accent(phi,dot)_1(t_1), dots, accent(phi,dot)_2(t_M);
  dots.v, , dots.down;
  accent(phi,dot)_(K)(t_0), accent(phi,dot)_(K)(t_1), dots, accent(phi,dot)_(K)(t_M))
  in RR^(K times (M+1))
$

and the data and right hand side (RHS) we define


$ bold(t) := vec(t_0, t_1, dots.v , t_M) in RR^((M+1) times 1), space bold(U) := vec(bold(u)_0^T, dots.v, bold(u)_M^T )  in  RR^((M+1) times D) $ 


and 

$ bold(F) := vec(bold(f)(bold(p), bold(u)_0, t_0 )^T, dots.v, bold(f)(bold(p), bold(u)_M, t_M )^T ) in RR^((M+1) times D). $


To approximate the integrals in @weakform2 for each test function $phi_(k)(t)$ we use Trapezoidal rule, which is equivalent to the following matrix product:

$ -accent(bold(Phi), dot)bold(U) approx bold(Phi)bold(F). $<disc>

Because of the compact support means at $t_0$ and $t_M$ the test functions are zero, so  that no quadrature weights are needed (the integral is approximated by summing discrete products).


$ -accent(bold(Phi), dot)bold(U) &=
-mat(
  accent(phi,dot)_1(t_0), accent(phi,dot)_1(t_1), dots, accent(phi,dot)_1(t_M);
  accent(phi,dot)_2(t_0), accent(phi,dot)_1(t_1), dots, accent(phi,dot)_2(t_M);
  dots.v, , dots.down;
  accent(phi,dot)_(K)(t_0), accent(phi,dot)_(K)(t_1), dots, accent(phi,dot)_(K)(t_M) 
)
mat(
u_01, u_02, dots, u_(0 D);
u_11, u_12, dots,u_(1 D) ;
  dots.v, , dots.down;
u_(M 1), u_(2 M), dots,u_(M D) 
) 
\

 bold(Phi)bold(F) &=
mat(
  phi_1(t_0), phi_1(t_1), dots, phi_1(t_M);
  phi_2(t_0), phi_1(t_1), dots, phi_2(t_M);
  dots.v, , dots.down ,;
  phi_(K)(t_0),phi_(K)(t_1), dots, phi_(K)(t_M)
)
mat(
f_1(bold(p), bold(u)_0, t_0),  dots,f_(D)(bold(p), bold(u)_0, t_0) ;
f_1(bold(p), bold(u)_1,t_1), dots,f_(D)(bold(p), bold(u)_1,t_1) ;
  dots.v,  dots.down;
f_1(bold(p), bold(u)_M,t_M), dots,f_(D)(bold(p), bold(u)_M,t_M) 
) 
$

For a given test function $phi_(k)(t)$, the approximation for one dimension of @weakform2 for the LHS and RHS are

 $ op("LHS:     ")  &  -integral_0^T accent(phi,dot)_(k)(t)u_(D)(t) dif t &&approx  -sum_(i=0)^M phi_(k)(t_i)u_(i D) \
 op("RHS:     ") &
 integral_0^T phi_(k)(t) f_(D)(bold(p),bold(u)(t),t) dif t &&approx  sum_(i=0)^M phi_(k)(t_i)f_(D)(bold(p),bold(u)_i,t_i) $


#pagebreak()
=  Interpretation of Weak Formulation <interpretationsection>

Inspecting the form of test functions: $ phi_(k)(t) = C exp(-9/([1 - ((t - t_k)/(m_t Delta t))^2 ]_+)) $ 

we see that instead of using a subscript $phi_(k)(t)$ we can define
$phi(t) = C exp(-9/([1 - (t/(m_t Delta t))^2 ]_+))$ and with symmetry 

$ phi_(k)(t) = phi(t-t_k)  attach(=, t:"symmetry")   phi(t_k - t) $  @weakform becomes

$ (bold(phi) * udot)(t_k) = integral_0^T bold(phi)(t_k -t) dot.circle  udot(t) dif t &= integral_0^T bold(phi)(t_k-t) dot.circle bold(f)(bold(p), bold(u)(t), t) dif t  = (bold(phi) * bold(f))(t_k) $

where $phi_(k)(t)$ is centered about $t_k$ with compact support  $phi_k in cal(C)^infinity_(C)((0,T),RR)$, $C$ is chosen such that $norm(phi_k)_2 =1,$ and $[dot]_+ := max(dot,0)$. Hence @weakform is equivalent to convolving the system with a test function $bold(phi)_(k)(t)$ and evaluating at $t_k$.


#text(fill: red)[ What are the forms of allowed for test functions? We want them to be smooth, but what about symmetric? Otherwise does the convolution analogy still work?]

#pagebreak()
= Test Function Minimum Radius Selection

In practice the error from numerical integration can dominate the noise if the radius of the test function is too small. Hence, we must optimize to find a minimum radius $underline(m)_t$ which all test functions must adhere to. To do this we can expand the integral of the residual into it's Fourier Basis. 






