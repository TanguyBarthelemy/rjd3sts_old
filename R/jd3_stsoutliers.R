NULL

#' Title
#'
#' @param y 
#' @param X 
#' @param X.td 
#' @param level 
#' @param slope 
#' @param noise 
#' @param seasonal 
#' @param ao 
#' @param ls 
#' @param so 
#' @param cv 
#' @param tcv 
#' @param estimation.forward 
#' @param estimation.backward 
#'
#' @return
#' @export
#'
#' @examples
sts.outliers<-function(y, X=NULL, X.td=NULL, level=1, slope=1, noise=1, seasonal=c("Trigonometric", "Dummy", "Crude", "HarrisonStevens", "Fixed", "Unused"),
              ao=T, ls=T, so=F, 
              cv=0, tcv=0, estimation.forward=c("Score", "Point", "Full"), 
              estimation.backward=c("Point", "Score", "Full")){
  
  if (!is.ts(y)){
    stop("y must be a time series")
  }
  seasonal<-match.arg(seasonal)
  estimation.forward<-match.arg(estimation.forward)
  estimation.backward<-match.arg(estimation.backward)
  
  
  if (! is.null(X.td)){
    td<-rjd3modelling::td.forTs(y, X.td)
    X<-cbind(X, td)
  }
      
  
  jsts<-.jcall("demetra/sts/r/StsOutliersDetection", "Ldemetra/sts/r/StsOutliersDetection$Results;", "process", .JD3_ENV$ts_r2jd(y), 
              as.integer(level), as.integer(slope), as.integer(noise), seasonal, .JD3_ENV$matrix_r2jd(X),
              ao, ls, so, cv, tcv, estimation.forward, estimation.backward)
  model<-list(
    y=as.numeric(y),
    variables=.JD3_ENV$proc_vector(jsts, "variables"),
    X=.JD3_ENV$proc_matrix(jsts, "regressors"),
    b=.JD3_ENV$proc_vector(jsts, "b"),
    bcov=.JD3_ENV$proc_matrix(jsts, "bvar"),
    components=.JD3_ENV$proc_matrix(jsts, "cmps"),
    linearized=.JD3_ENV$proc_vector(jsts, "linearized")
  )
  
  l0<-.JD3_ENV$proc_numeric(jsts, "initialbsm.levelvar")
  s0<-.JD3_ENV$proc_numeric(jsts, "initialbsm.slopevar")
  seas0<-.JD3_ENV$proc_numeric(jsts, "initialbsm.seasvar")
  n0<-.JD3_ENV$proc_numeric(jsts, "initialbsm.noisevar")
  tau0=.JD3_ENV$proc_matrix(jsts, "initialtau")
  
  
  l1<-.JD3_ENV$proc_numeric(jsts, "finalbsm.levelvar")
  s1<-.JD3_ENV$proc_numeric(jsts, "finalbsm.slopevar")
  seas1<-.JD3_ENV$proc_numeric(jsts, "finalbsm.seasvar")
  n1<-.JD3_ENV$proc_numeric(jsts, "finalbsm.noisevar")
  tau1=.JD3_ENV$proc_matrix(jsts, "finaltau")
  
  ll0<-proc_diffuselikelihood(jsts, "initiallikelihood.")
  ll1<-proc_diffuselikelihood(jsts, "finallikelihood.")
  
  return(structure(list(
    model=model,
    bsm=list(
      initial=list(
        level=l0,
        slope=s0,
        seasonal=seas0,
        noise=n0,
        tau=tau0
      ),
      final=list(
        level=l1,
        slope=s1,
        seasonal=seas1,
        noise=n1,
        tau=tau1
      )
    ),
    likelihood=list(initial=ll0, final=ll1)),
    class="JD3_STS_OUTLIERS"))
}