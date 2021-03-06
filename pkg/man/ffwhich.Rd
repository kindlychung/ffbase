% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/ffwhich.R
\name{ffwhich}
\alias{ffwhich}
\title{Create an index from a filter statement}
\usage{
ffwhich(x, expr, ...)
}
\arguments{
\item{x}{\code{ff} or \code{ffdf} object}

\item{expr}{R code that evaluates to a logical}

\item{...}{not used}
}
\description{
\code{ffwhich} creates an \code{\link{ff}} integer index vector
from a filter expression. The resulting vector can be used to index or subset
a ffdf or ff vector.
}
\examples{
# create a ff vector
x <- ff(10:1)
# make an ff index vector
idx <- ffwhich(x, x < 5)
# use it to retrieve values from x
x[idx][]

# create a ffdf data.frame
dat <- ffdf(x1=x, y1=x)
# create an ff index vector from a filter statement
idx <- ffwhich(dat, x1 < 5 & y1 > 2)
# use it to select data from the data.frame
dat[idx,][,]
}
\seealso{
ffindexget ffindexset
}

