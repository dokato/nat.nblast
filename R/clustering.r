#' Cluster a set of neurons
#'
#' Given a vector of neuron identifiers use hclust to carry out a
#' hierarchical clustering. The default value of distfun will handle square
#' distance matrices and R.
#' @param neuron_names character vector of neuron identifiers.
#' @param method clustering method (default Ward's).
#' @param scoremat score matrix to use (see \code{sub_score_mat} for details of
#'   default).
#' @param distfun function to convert distance matrix returned by
#'   \code{sub_dist_mat} into R dist object (default=as.dist).
#' @param ... additional parameters passed to hclust.
#' @inheritParams sub_dist_mat
#' @return An object of class \code{\link{hclust}} which describes the tree
#'   produced by the clustering process.
#' @export
#' @family scoremats
#' @seealso \code{\link{hclust}, \link{dist}}
#' @examples
#' \dontrun{
#' data(kcs20, package='nat')
#' hckcs=nhclust(names(kcs20))
#' # dividide hclust object into 3 groups
#' library(dendroextras)
#' plot(colour_clusters(hckcs, k=3))
#' # 3d plot of neurons in those clusters (with matching colours)
#' library(nat)
#' plot3d(hckcs, k=3, db=kcs20)
#' # names of neurons in 3 groups
#' subset(hckcs, k=3)
#' }
nhclust <- function(neuron_names, method='ward', scoremat=NULL, distfun=as.dist, ..., maxneurons=4000) {
  subdistmat <- sub_dist_mat(neuron_names, scoremat, maxneurons=maxneurons)
  if(min(subdistmat) < 0)
    stop("Negative distances not allowed. Are you sure this is a distance matrix?")
  hclust(distfun(subdistmat), method=method, ...)
}


#' Methods to identify and plot groups of neurons cut from an hclust object
#'
#' @description \code{plot3d.hclust} uses \code{plot3d} to plot neurons from
#'   each group, cut from the \code{hclust} object, by colour.
#' @details Note that the colours are in the order of the dendrogram as assigned
#'   by \code{colour_clusters}.
#' @param x an \code{\link{hclust}} object generated by \code{\link{nhclust}}.
#' @param k number of clusters to cut from \code{\link{hclust}} object.
#' @param h height to cut \code{\link{hclust}} object.
#' @param groups numeric vector of groups to plot.
#' @param col colours for groups (directly specified or a function).
#' @param ... additional arguments for \code{plot3d}
#' @return A list of rgl IDs for plotted objects (see \code{\link[rgl]{plot3d}}).
#' @export
#' @seealso
#' \code{\link{nhclust}, \link[rgl]{plot3d}, \link{slice}, \link{colour_clusters}}
#' @importFrom dendroextras slice
#' @examples
#' # 20 Kenyon cells
#' data(kcs20, package='nat')
#' # calculate mean, normalised NBLAST scores
#' x=nblast(kcs20, kcs20, normalised=TRUE)
#' x=(x+t(x))/2
#' # note that specifying db explicitly could be avoided by use of the
#' # \code{nat.default.neuronlist} option.
#' plot3d(hclust(as.dist(x)), k=3, db=kcs20)
plot3d.hclust <- function(x, k=NULL, h=NULL, groups=NULL, col=rainbow, ...) {
  # Cut the dendrogram into k groups of neurons. Note that these will now have
  # the neurons in dendrogram order
  kgroups <- slice(x,k,h)
  k <- max(kgroups)
  if(is.function(col))
    col <- col(k)
  else if(length(col)==1) col=rep(col,k)
  neurons <- names(kgroups)

  if(!is.null(groups)){
    matching <- kgroups%in%groups
    kgroups <- kgroups[matching]
    neurons <- neurons[matching]
  }
  # NB we need to substitute right away to ensure that the non-standard
  # evaluation of col does not fail with a lookup problem for kgroups
  nat:::plot3d.character(neurons, col=substitute(col[kgroups]), ..., SUBSTITUTE=FALSE)
}


#' Return the labels of items in 1 or more groups cut from hclust object
#'
#' @details Only one of \code{h} and \code{k} should be supplied.
#'
#' @inheritParams dendroextras::slice
#' @param groups a vector of which groups to inspect.
#'
#' @return A character vector of labels of selected items
#' @export
#' @importFrom dendroextras slice
subset.hclust <- function(x, k=NULL, h=NULL, groups=NULL, ...) {
  kgroups=slice(x, k, h)

  neurons=names(kgroups)

  if(!is.null(groups)){
    matching=kgroups%in%groups
    kgroups=kgroups[matching]
    neurons=neurons[matching]
  }
  neurons
}


#' Cluster NBLAST scores using density clustering algorithm
#'
#' @param score_matrix a raw NBLAST score matrix.
#' @param ... extra arguments to pass to
#'   \code{\link[densityClust]{densityClust}}.
#'
#' @return An \code{ndclust} object (basically a \code{densityCluster} object,
#'   see \link[densityClust]{densityClust}) with clusters assigned to all
#'   neurons. See \code{\link[densityClust]{findClusters}}.
#'
#' @importFrom densityClust densityClust
#' @importFrom densityClust findClusters
#' @export
ndclust <- function(score_matrix, ...) {
  dist_matrix <- sub_dist_mat(scoremat=score_matrix)
  dc <- densityClust(as.dist(dist_matrix), ...)
  clusters <- findClusters(dc)
  class(clusters) <- c('ndclust', class(clusters))
  clusters
}


#' Plot neurons in 3D based on density clustering
#'
#' @param x an \code{\link{ndclust}} object detailing the clustering of neurons.
#' @param groups numeric vector of groups to plot.
#' @param col colours for groups (directly specified or a function).
#' @param ... additional arguments for \code{plot3d}.
#'
#' @return A list of rgl IDs for plotted objects (see \code{\link[rgl]{plot3d}}).
#' @export
plot3d.ndclust <- function(x, groups=NULL, col=rainbow, ...) {
  k <- length(unique(x$clusters))
  if(is.function(col))
    col <- col(k)
  else if(length(col)==1) col=rep(col,k)
  neurons <- attr(x$rho, 'names')

  neuron_colours <- col[x$clusters]
  if(!is.null(groups)){
    matching <- x$clusters %in% groups
    neuron_colours <- neuron_colours[matching]
    neurons <- neurons[matching]
  }

  nat:::plot3d.character(neurons, col=neuron_colours, ..., SUBSTITUTE=FALSE)
}
