# plotCircular.R
# circular plot
## Changes
## 7/2/10: incorporated titles/axes labekls/colour setting/auto legend



#' Circular Plot Using Segments
#' 
#' A circular plot useful for visualising monthly or weekly data.
#' 
#' A circular plot can be useful for spotting the shape of the seasonal
#' pattern. This function can be used to plot any circular patterns, e.g.,
#' weekly or monthly. The number of segments will be the length of the variable
#' \code{area1}.
#' 
#' The plots are also called rose diagrams, with the segments then called
#' \sQuote{petals}.
#' 
#' @param area1 variable to plot, the area of the segments (or petals) are
#' proportional to this variable.
#' @param area2 2nd variable to plot (optional), the area of the segments are
#' plotted in grey.
#' @param spokes spokes that overlay segments, for example standard errors
#' (optional).
#' @param scale scale the overall size of the segments (default:0.8).
#' @param labels optional labels to appear at the ends of the segments (there
#' should be as many labels as there are \code{area1}).
#' @param stats put area values at the ends of the segments, default:TRUE.
#' @param dp decimal places for statistics, default:1.
#' @param clockwise plot in a clockwise direction, default:TRUE.
#' @param spoke.col spoke colour, default:black.
#' @param lines add dotted lines to separate petals, default:FALSE.
#' @param centrecirc controls the size of the circle at the centre of the plot,
#' default:0.03.
#' @param main title for plot, default:blank
#' @param xlab x axis label, default:blank
#' @param ylab y axis label, default:blank
#' @param pieces.col colours for circular pieces, default:\sQuote{white} for
#' 1st and \sQuote{grey} for second variable. Note that a list of available
#' colours may be found with \sQuote{colors()}
#' @param length make the length of the segments proportional to the dependent
#' variable, default:FALSE
#' @param legend whether to include legend or not, default:TRUE when plotting
#' two variables
#' @param auto.legend list of parameters for legend, see \code{\link{legend}}
#' @param \dots additional arguments to \code{\link{plot}} and/or
#' \code{\link{legend}}. See \code{\link{par}} for more details
#' @author Adrian Barnett \email{a.barnett<at>qut.edu.au}
#' @references Fisher, N.I. (1993) \emph{Statistical Analysis of Circular
#' Data}. Cambridge University Press, Cambridge.
#' @examples
#' \donttest{
#' # months (dummy data)
#' plotCircular(area1=seq(1,12,1), scale=0.7, labels=month.abb, dp=0)
#' # weeks (random data)
#' daysoftheweek = c('Monday','Tuesday','Wednesday','Thursday','Friday',
#' 'Saturday','Sunday')
#' weekfreq = table(round(runif(100, min=1, max=7)))
#' plotCircular(area1=weekfreq, labels=daysoftheweek, dp=0)
#' # Observed number of AFL players with expected values
#' data(AFL)
#' plotCircular(area1=AFL$players, area2=AFL$expected, scale=0.72,
#'   labels=month.abb, dp=0, lines=TRUE, legend=FALSE)
#' plotCircular(area1=AFL$players, area2=AFL$expected, scale=0.72,
#'   labels=month.abb, dp=0, lines=TRUE, pieces.col=c("green","red"),
#'   auto.legend=list(labels=c("Obs","Exp"), title="# players"),
#'   main="Observed and Expected AFL players")
#' }
#' 
#' @export 
plotCircular<-function(area1,area2=NULL,spokes=NULL,
                       scale=0.8,labels,stats=TRUE,dp=1,
                       clockwise=TRUE,spoke.col='black',lines=FALSE,
                       centrecirc=0.03,
                       main="", xlab="", ylab="",
                       pieces.col=c("white","gray"),
                       length=FALSE,
                       legend=TRUE,
                       auto.legend=list(x="bottomright",fill=NULL, 
                         labels=NULL, title=""), ...){

  ## NB: need some serious argumnt checking
  ## NB2: can find list of available colours using colors()

  ## No legend if only one variable and check area vars same length
  if (is.null(area2)) {
    legend <- FALSE
  } else {
    if (length(area1)!=length(area2))
      cat("Warning: length of", deparse(substitute(area1)),
          "and", deparse(substitute(area2)),"not equal\n")
  }
  
  ##print(pieces.col)
  density.1 <- density.2 <- 0
  if (pieces.col[1] != "white") density.1 <- NA
  if (length(pieces.col)==2) {
    if (pieces.col[2] != "white") density.2 <- NA
  }

  op <- par(no.readonly = TRUE) # the whole list of settable par's.
  on.exit(par(op)) # restore graphic settings whenever function exits

  bins<-length(area1)
  clockstart=pi/2 # default clock start at 12 o'clock
  half<- 2*pi/(bins*2) # for moving text/spokes half-way round
  if (clockwise==TRUE) mult=-1 else mult=1

  ## First plot a circle (of radius 1) as a frame
  detail<-200 # number that controls graphical detail of cheeses
  circle<-matrix(nrow=detail+1,ncol=2,data=0)
  frac<-1/detail
  for (i in 1:(detail+1)){
    circle[i,1]<-1*cos(2*pi*i*frac)
    circle[i,2]<-1*sin(2*pi*i*frac)
  }
  plot(circle,type='l',col='black',bty='n',yaxt='n',main=main,
       xlab=xlab, ylab=ylab, xlim=c(-1,1),ylim=c(-1,1),xaxt='n', ...)

  ## scale cheeses to their area
  aarea1<-area1
  if(is.null(area2)==FALSE){
      aarea2<-area2
  }
  if(length==F){
     aarea1<-sqrt(area1*12/pi)
     if(is.null(area2)==FALSE){
        aarea2<-sqrt(area2*12/pi)
     }
  }

  ## scale the area to the maximum multiplied by the user-defined scale
  ## draw the cheeses
  for (cheeseno in 1:bins){
    if(is.null(area2)==TRUE){
      scaled1<-scale*aarea1/max(aarea1)
      cheese<-matrix(nrow=102,ncol=2,data=0)
      start<-2*pi*((cheeseno-1)/bins)+clockstart
      frac<-1/100
      cheese[1,1]<-centrecirc*mult*cos((2*pi*frac/bins)+start)
      cheese[1,2]<-centrecirc*sin((2*pi*frac/bins)+start)
      cheese[102,1]<-centrecirc*mult*cos((2*pi*100*frac/bins)+start)
      cheese[102,2]<-centrecirc*sin((2*pi*100*frac/bins)+start)
      for (i in 1:100){
        cheese[i+1,1]<-mult*scaled1[cheeseno]*cos((2*pi*i*frac/bins)+start)
        cheese[i+1,2]<-scaled1[cheeseno]*sin((2*pi*i*frac/bins)+start)
      }
      polygon(cheese,density=density.1,angle=0,lty=1,lwd=1,border="black",
              col=pieces.col[1]) 
    }
    
    ## plot with two segments #
    ## 1st pattern
    if(is.null(area2)==FALSE){
      allarea<-c(aarea1,aarea2)
      scaled1<-scale*aarea1/max(allarea)
      scaled2<-scale*aarea2/max(allarea)
      cheese1<-matrix(nrow=52,ncol=2,data=0)
      cheese2<-matrix(nrow=52,ncol=2,data=0)
      start<-2*pi*((cheeseno-1)/bins)+clockstart
      frac<-1/100


      ## centrecirc: do not start at c(0,0) to prevent a dense block
      cheese1[1,1]<-centrecirc*mult*cos((2*pi*0*frac/bins)+start)
      cheese1[1,2]<-centrecirc*sin((2*pi*0*frac/bins)+start)
      cheese1[52,1]<-centrecirc*mult*cos((2*pi*51*frac/bins)+start)
      cheese1[52,2]<-centrecirc*sin((2*pi*51*frac/bins)+start)
      for (i in 1:50){
        cheese1[i+1,1]<-mult*scaled1[cheeseno]*cos((2*pi*i*frac/bins)+start)
        cheese1[i+1,2]<-scaled1[cheeseno]*sin((2*pi*i*frac/bins)+start)
      }
      polygon(cheese1,density=density.1,angle=0,lty=1,lwd=1,border="black",
              col=pieces.col[1]) 

      ## 2nd pattern
      start<-2*pi*((cheeseno-1)/bins)+clockstart
      cheese2[1,1]<-centrecirc*mult*cos((2*pi*50*frac/bins)+start)
      cheese2[1,2]<-centrecirc*sin((2*pi*50*frac/bins)+start)
      cheese2[52,1]<-centrecirc*mult*cos((2*pi*100*frac/bins)+start)
      cheese2[52,2]<-centrecirc*sin((2*pi*100*frac/bins)+start)
      for (i in 51:100){
        cheese2[i+1-50,1]<-mult*scaled2[cheeseno]*cos((2*pi*i*frac/bins)+start)
        cheese2[i+1-50,2]<-scaled2[cheeseno]*sin((2*pi*i*frac/bins)+start)
      }
      polygon(cheese2,density=density.2,angle=0,lty=1,lwd=1,border="black",
              col=pieces.col[2]) 
    } 
  }
  ## add the text
  if (is.null(labels)==FALSE&stats==FALSE){
    for (cheeseno in 1:bins){
      x<-mult*0.92*cos((2*pi*cheeseno/bins)+start+half)
      y<-0.92*sin((2*pi*cheeseno/bins)+start+half)
      text(x,y,labels[cheeseno])
    }
  }

  ## add the labels with stats
  if (is.null(labels)==FALSE&stats==TRUE){
    clabel2<-formatC(area1, format="f", digits=dp) # convert to character
    for (cheeseno in 1:bins){
      x<-mult*0.86*cos((2*pi*cheeseno/bins)+start+half)
      y<-0.86*sin((2*pi*cheeseno/bins)+start+half)
      label1<-labels[cheeseno]
      label<-paste(label1,"\n",clabel2[cheeseno])
      text(x,y,label)
    }
  }

  ## add spokes representing uncertainty
  if (is.null(spokes)==FALSE){
    scaleds<-scale*spokes/max(spokes)
    halfcheese<-(2*pi)/(bins*2);
    for (cheeseno in 1:bins){
      spokes<-matrix(data=0,nrow=2,ncol=2)
      spokes[1,1]<-centrecirc*mult*scaleds[cheeseno]*
        cos((2*pi*cheeseno/bins)+start+half)
      spokes[1,2]<-centrecirc*scaleds[cheeseno]*
        sin((2*pi*cheeseno/bins)+start+half)
      spokes[2,1]<-mult*scaleds[cheeseno]*cos((2*pi*cheeseno/bins)+start+half)
      spokes[2,2]<-scaleds[cheeseno]*sin((2*pi*cheeseno/bins)+start+half)
      lines(spokes,pch=0,type='l',col=spoke.col,lty=1,lwd=1.5) 
    }
  } # end of spokes

  ## add dotted lines to separate months
  if (lines==TRUE){
    halfcheese<-(2*pi)/(bins*2);
    for (cheeseno in 1:bins){
      breaks<-matrix(data=0,nrow=2,ncol=2)
      breaks[1,1]<-centrecirc*cos((2*pi*cheeseno/bins)+start)
      breaks[1,2]<-centrecirc*sin((2*pi*cheeseno/bins)+start)
      breaks[2,1]<-cos((2*pi*cheeseno/bins)+start)
      breaks[2,2]<-sin((2*pi*cheeseno/bins)+start)
      lines(breaks,pch=0,type='l',lty=3,lwd=1) 
    }
  } # end of lines

  ## add legend if set
  if (legend) {
    if (length(auto.legend$x)==0) {
      legend.x <- "bottomright"
    } else {
      legend.x <- auto.legend$x
    }
    
    ##if (length(auto.legend$title)==0) {
    ##  title <- NULL
    ##} else {
    ##  title <- auto.legend$title
    ##}
    
    if (length(auto.legend$labels)==0){
      labels <- c(deparse(substitute(area1)),
                  deparse(substitute(area2)))
    } else {
      labels <- auto.legend$labels
    }
    
    if (length(auto.legend$fill)==0){
      fill <- pieces.col
    } else {
      fill <- auto.legend$fill
    }
    
    ##print(legend.x)
    ##print(labels)
    ##print(fill)
    ##print(title)
    legend(x=legend.x, legend=labels, title=auto.legend$title, fill=fill, ...)
  }
  
} # end of function

## examples
##area<-c(8,7,6,5,4,3.5,2)
##plotCircular(area,scale=0.7,clockwise=TRUE,labels=c("Mon","Tue","Wed","Thu","Fri","Sat","Sun"))
##plotCircular(area,scale=0.8,clockwise=FALSE,labels=c("Mon","Tue","Wed","Thu","Fri","Sat","Sun"))

##area<-c(12,11,6,5,4,3,2)
##plotCircular(area,scale=0.8,clockwise=TRUE,labels=c("Mon","Tue","Wed","Thu","Fri","Sat","Sun"))


