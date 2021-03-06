% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/droplevels.R
\name{droplevels.ff}
\alias{droplevels.ff}
\title{The function \code{droplevels} is used to drop unused levels from a \code{ff}
 factor or , more commonly, from factors in a \code{ffdf}}
\usage{
\method{droplevels}{ff}(x, ..., inplace = FALSE)
}
\arguments{
\item{x}{\code{ff} object}

\item{...}{not used}

\item{inplace}{if \code{TRUE} the columns will be physically changed,
otherwise (default) a new \code{ff} vector will be created}
}
\value{
\code{ff} object where levels of factors are dropped
}
\description{
The function \code{droplevels} is used to drop unused levels from a \code{ff}
 factor or , more commonly, from factors in a \code{ffdf}
}
\seealso{
\code{\link{droplevels}} \code{\link{droplevels.ffdf}}
}

