# To prevent warnings: no visible binding for global variable
x <- y <- pps <- correlation <- NULL



pps_break_interval = function() {
  return(0.2)
}

pps_breaks = function() {
  return(seq(0, 1, pps_break_interval()))
}

pps_minor_breaks = function() {
  minor_breaks = seq(0, 1, pps_break_interval() / 2)
  return(setdiff(minor_breaks, pps_breaks()))
}

correlation_breaks = function() {
  # range twice as long so interval twice as long
  return(seq(-1, 1, pps_break_interval() * 2))
}

theme_ppsr = function(){
  ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      NULL
    )
}


#' Visualize the Predictive Power scores of the entire dataframe, or given a target
#'
#' If \code{y} is specified, \code{visualize_pps} returns a barplot of the PPS of
#' every predictor on the specified target variable.
#' If \code{y} is not specified, \code{visualize_pps} returns a heatmap visualization
#' of the PPS for all X-Y combinations in a dataframe.
#'
#' @inheritParams score_predictors
#' @param y string, column name of target variable,
#'     can be left \code{NULL} to visualize all X-Y PPS
#' @param color_value_high string, hex value or color name used for upper limit of PPS gradient (high PPS)
#' @param color_value_low string, hex value or color name used for lower limit of PPS gradient (low PPS)
#' @param color_text string, hex value or color name used for text, best to pick high contrast with \code{color_value_high}
#' @param include_target boolean, whether to include the target variable in the barplot
#'
#' @return a ggplot object, a vertical barplot or heatmap visualization
#' @export
#'
#' @examples
#' visualize_pps(iris, y = 'Species')
#'
#' \donttest{visualize_pps(iris)}
#'
#' \donttest{visualize_pps(mtcars, do_parallel = TRUE, n_cores = 2)}
visualize_pps = function(df,
                         y = NULL,
                         color_value_high = '#08306B',
                         color_value_low = '#FFFFFF',
                         color_text = '#FFFFFF',
                         include_target = TRUE,
                         ...) {
  if (is.null(y)) {
    p = ggplot2::ggplot(score_df(df, ...), ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_tile(ggplot2::aes(fill = pps)) +
      ggplot2::geom_text(ggplot2::aes(label = format_score(pps)), col = color_text) +
      ggplot2::scale_x_discrete(limits = colnames(df)) +
      ggplot2::scale_y_discrete(limits = rev(colnames(df))) +
      ggplot2::labs(x = 'predictor', y = 'target') +
      theme_ppsr()
  } else {
    res = score_predictors(df, y, ...)
    if (!include_target) {
      res = res[res$x != y, ]
    }
    p = ggplot2::ggplot(res,
                        ggplot2::aes(x = pps, y = stats::reorder(x, pps))) +
      ggplot2::geom_col(ggplot2::aes(fill = pps)) +
      ggplot2::geom_text(ggplot2::aes(label = format_score(pps)), hjust = 0) +
      ggplot2::scale_x_continuous(breaks = pps_breaks(), minor_breaks = pps_minor_breaks(), limits = c(0, 1.05)) +
      ggplot2::labs(y = 'feature') +
      theme_ppsr() +
      ggplot2::theme(panel.grid.major.x = ggplot2::element_line(colour = "grey92"),
                     panel.grid.minor.x = ggplot2::element_line(size = ggplot2::rel(0.5), colour = "grey92")
      )
  }
  p = p +
    ggplot2::scale_fill_gradient(low = color_value_low, high = color_value_high,
                                 limits = range(pps_breaks()), breaks = pps_breaks()) +
    ggplot2::expand_limits(fill = range(pps_breaks()))
  return(p)
}



#' Visualize the correlation matrix
#'
#' @inheritParams score_correlations
#' @param color_value_positive color used for upper limit of gradient (high positive correlation)
#' @param color_value_negative color used for lower limit of gradient (high negative correlation)
#' @param color_text color used for text, best to pick high contrast with \code{color_value_high}
#' @param include_missings bool, whether to include the variables without correlation values in the plot
#'
#' @return a ggplot object, a heatmap visualization
#' @export
#'
#' @examples
#' visualize_correlations(iris)
visualize_correlations = function(df,
                                  color_value_positive = '#08306B',
                                  color_value_negative = '#8b0000',
                                  color_text = '#FFFFFF',
                                  include_missings = FALSE,
                                  ...) {
  df_correlations = score_correlations(df, ...)

  if (include_missings) {
    cnames = colnames(df)
  } else {
    cnames = unique(df_correlations[['x']])
  }

  # TODO standardize in heatmap function
  p = ggplot2::ggplot(df_correlations, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_tile(ggplot2::aes(fill = correlation)) +
    ggplot2::geom_text(ggplot2::aes(label = format_score(correlation)), col = color_text) +
    ggplot2::scale_x_discrete(limits = cnames) +
    ggplot2::scale_y_discrete(limits = rev(cnames)) +
    ggplot2::scale_fill_gradient2(low = color_value_negative,
                                  mid = '#FFFFFF',
                                  high = color_value_positive,
                                  limits = range(correlation_breaks()),
                                  breaks = correlation_breaks()) +
    ggplot2::expand_limits(fill = range(correlation_breaks())) +
    theme_ppsr()
  return(p)
}


#' Visualize the PPS & correlation matrices
#'
#' @inheritParams visualize_pps
#' @inheritParams visualize_correlations
#' @param nrow numeric, number of rows, either 1 or 2
#'
#' @return a grob object, a grid with two ggplot2 heatmap visualizations
#' @export
#'
#' @examples
#' \donttest{visualize_both(iris)}
#'
#' \donttest{visualize_both(mtcars, do_parallel = TRUE, n_cores = 2)}
visualize_both = function(df,
                          color_value_positive = '#08306B',
                          color_value_negative = '#8b0000',
                          color_text = '#FFFFFF',
                          include_missings = TRUE,
                          nrow = 1,
                          ...) {
  plot_pps = visualize_pps(df,
                           color_value_high = color_value_positive,
                           color_text = color_text,
                           ...)
  plot_cor = visualize_correlations(df,
                                    color_value_positive = color_value_positive,
                                    color_value_negative = color_value_negative,
                                    color_text = color_text,
                                    include_missings = include_missings)
  return(gridExtra::grid.arrange(plot_pps, plot_cor, nrow = nrow))
}

