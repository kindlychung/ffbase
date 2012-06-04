#' Save ffdf data.frames in a directory
#'
#' \code{save.ffdf} saves all ffdf data.frames in the given \code{dir}. Each column
#' is stored as with filename <ffdfname>$<colname>.ff. All variables given in "..." are stored in ".RData" in the same directory.
#' The data can be reloaded by starting a R session in the directory or by using \code{\link{load.ffdf}}.
#' @example ../examples/save_ffdf.R
#' @param ... \code{ffdf} data.frames, \code{ff} vectors, or other variables to be saved in the directory
#' @param dir path where .rdata file will be saved and all columns of supplied \code{ffdf}'s. It will be created if it doesn't exist.
#' @param clone should the data.frame be cloned?
#' @param relativepath \code{logical} if \code{TRUE} the stored ff vectors will have relative paths, making moving the data to another storage a simple
#' copy operation.
#' @seealso \code{\link{load.ffdf}} 
#' @export
save.ffdf <- function(..., dir="./ffdb", clone=FALSE, relativepath=TRUE){
   names <- as.character(substitute(list(...)))[-1L]
   dir.create(dir, showWarnings=FALSE, recursive=TRUE)
   
   oldwd <- setwd(dir)
   on.exit(setwd(oldwd))
   
   for (n in names){
     x = get(n, pos=1)
     if (is.ffdf(x)) {
       if (isTRUE(clone)){
         x <- clone(x)
       }
       assign(n, move.ffdf(x, dir=".", name=n, relativepath=relativepath))
     }
   }
   
   save(list=names, file=".RData")
   
   rp <- file(".Rprofile", "wt")
   writeLines(".First<-", rp)
   writeLines(deparse(first), rp)
   close(rp)
   
   if (relativepath && !clone){
     for (n in names){
       x = get(n)
       if (is.ffdf(x)){
         for (i in physical(x)){
           filename(i) <- filename(i)
         }
         close(x)
       } else if (is.ff(x)){
          filename(x) <- filename(x)
          close(x)
       }
     }
   }
}

#' Moves all the columns of ffdf data.frames into a directory
#'
#' \code{move.ffdf} saves all columns into the given \code{dir}. Each column
#' is stored as with filename <ffdfname>$<colname>.ff. 
#' If you want to store the data for an other session please use \code{\link{save.ffdf}} or \code{\link{pack.ffdf}}
#' @example ../examples/save_ffdf.R
#' @param x \code{ffdf} data.frame to be moved
#' @param dir path were all of supplied \code{ffdf}'s, will be saved. It will be created if it doesn't exist.
#' @param name name to be used as data.frame name
#' @param relativepath If \code{TRUE} the \code{ffdf} will contain relativepaths. Use with care...
#' @seealso \code{\link{load.ffdf}} \code{\link{save.ffdf}} 
#' @export
move.ffdf <- function(x, dir=".", name=as.character(substitute(x)), relativepath=FALSE){  
  dir.create(dir, showWarnings=FALSE, recursive=TRUE)
  for (colname in names(x)){
    ffcol <- x[[colname]]
    
    ffcolname <- file.path(dir, paste(name, "$", colname, ".ff", sep=""))
    
    # move file to right directory
    filename(ffcol) <- ffcolname
    
    # set path to relative path, BEWARE if wd is changed this should be reset!
    if (isTRUE(relativepath)){
      physical(ffcol)$filename <- ffcolname
    }
  }
  close(x)
  x
}

#' Loads ffdf data.frames from a directory
#'
#' \code{load.ffdf} loads ffdf data.frames from the given \code{dir}, that were stored using \code{\link{save.ffdf}}. Each column
#' is stored as with filename <ffdfname>$<colname>.ff. All variables are stored in .RData in the same directory.
#' The data can be loaded by starting a R session in the directory or by using \code{\link{load.ffdf}}.
#' @example ../examples/save_ffdf.R
#' @param dir path from where the data should be loaded
#' @param envir environment where the stored variables will be loaded into.
#' @seealso \code{\link{load.ffdf}} 
#' @export
load.ffdf <- function(dir, envir=parent.frame()){
  oldwd <- setwd(dir)
  on.exit(setwd(oldwd))
  
  env <- new.env()
  
  load(".RData", envir=env)
  names <- ls(envir=env, all.names=TRUE)
  
  for (n in names){
    x = get(n, envir=env)
    if (is.ffdf(x)){
      for (i in physical(x)){
        filename(i) <- filename(i)
      }
      close(x)
    } else if (is.ff(x)){
      filename(x) <- filename(x)
      close(x)
    }
    assign(n, x, envir=envir)
  }
  invisible(env)
}

#' Packs ffdf data.frames into a compressed file
#'
#' \code{pack.ffdf} stores ffdf data.frames into the given \code{file} for easy archiving and movement of data.
#' The file can be restored using \code{\link{unpack.ffdf}}. If \code{file} ends with ".zip", the package will be zipped
#' otherwise it will be tar.gz-ed.
#' @example ../examples/save_ffdf.R
#' @param file packaged file, zipped or tar.gz.
#' @param ... ff objects to be packed
#' @seealso \code{\link{save.ffdf}} \code{\link{unpack.ffdf}} 
#' @export
pack.ffdf <- function(file, ...){
  td <- tempfile("pack")
  save.ffdf(..., dir=td, clone=TRUE, relativepath=TRUE)
  
  file.create(file)
  file <- file_path_as_absolute(file)
  file.remove(file)
  
  oldwd <- setwd(td)
  on.exit(setwd(oldwd))
  
  d <- c(".Rprofile", ".RData", dir(td))
  
  # if file extension is zip, zip it otherwise tar.gz it
  switch( file_ext(file)
        , zip = zip(zipfile=file, files=d)
        , tar(tarfile=file, ".", compression="gzip")
        )
}

#' Unpacks previously stored ffdf data.frame into a directory
#'
#' \code{unpack.ffdf} restores ffdf data.frames into the given \code{dir}, that were stored using \code{\link{pack.ffdf}}.
#' If \code{dir} is \code{NULL} (the default) the data.frames will restored in a temporary directory.
#' if
#' @example ../examples/save_ffdf.R
#' @param file packaged file, zipped or tar.gz.
#' @param dir path where the data will be saved and all columns of supplied \code{ffdf}'s. It will be created if it doesn't exist.
#' @param envir the environment where the stored variables should be loaded into.
#' @seealso \code{\link{load.ffdf}} \code{\link{pack.ffdf}} 
#' @export
unpack.ffdf <- function(file, dir=NULL, envir=parent.frame()){
  if (is.null(dir)){ 
    dir <- tempfile("unpack")
  }
  
  switch( file_ext(file)
        , zip = unzip(zipfile=file, exdir=dir)
        , untar(tarfile=file, exdir=dir)
  )
  
  env <- load.ffdf(dir, envir=envir)
  invisible(env)
}

first <- function(){
  
  if (!require(ffbase)){
    stop("Please install package ffbase, otherwise the files cannot be loaded.")
  }
  
  for (n in ls()){
    x = get(n)
    if (is.ffdf(x)){
      for (i in physical(x)){
        filename(i) <- filename(i)
      }
      close(x)
    } else if (is.ff(x)){
      filename(x) <- filename(x)
      close(x)
    }
  }
}

# x <- as.ffdf(iris)
# pack.ffdf("test.zip", x)