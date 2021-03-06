test_that("PPS is between zero and one", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = rnorm(n = n),
    y2 = runif(n = n),
    y3 = x,
    y4 = x ^ 2 + rnorm(n = n),
    y5 = as.numeric(x > 0)
  )

  pps1 = score(df, 'x', 'y1', verbose = FALSE)[['pps']]
  pps2 = score(df, 'x', 'y2', verbose = FALSE)[['pps']]
  pps3 = score(df, 'x', 'y3', verbose = FALSE)[['pps']]
  pps4 = score(df, 'x', 'y4', verbose = FALSE)[['pps']]
  pps5 = score(df, 'x', 'y5', verbose = FALSE)[['pps']]

  min_pps = 0
  max_pps = 1

  expect_true(pps1 >= min_pps & pps1 <= max_pps)
  expect_true(pps2 >= min_pps & pps2 <= max_pps)
  expect_true(pps3 >= min_pps & pps3 <= max_pps)
  expect_true(pps4 >= min_pps & pps4 <= max_pps)
  expect_true(pps5 >= min_pps & pps4 <= max_pps)
})


test_that("The calculated PPS is stable", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = x ^ 2 + rnorm(n = n),
    y2 = as.numeric(x > 0)
  )

  pps1.1 = score(df, 'x', 'y1', verbose = FALSE)[['pps']]
  pps2.1 = score(df, 'x', 'y2', verbose = FALSE)[['pps']]

  pps1.2 = score(df, 'x', 'y1', verbose = FALSE)[['pps']]
  pps2.2 = score(df, 'x', 'y2', verbose = FALSE)[['pps']]

  expect_equal(pps1.1, pps1.2)
  expect_equal(pps2.1, pps2.2)
})


test_that("Classification works for characters, booleans, and binary numerics", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = as.logical(x > 0),
    y2 = as.numeric(x > 0),
    y3 = sample(c('a', 'b', 'c'), size = n, replace = TRUE)
  )

  result1 = score(df, 'x', 'y1', verbose = FALSE)
  result2 = score(df, 'x', 'y2', verbose = FALSE)
  result3 = score(df, 'x', 'y3', verbose = FALSE)


  expect_equal(result1$model_type, 'classification')
  expect_equal(result2$model_type, 'classification')
  expect_equal(result3$model_type, 'classification')
})


test_that("Regression works for doubles and integers", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = as.integer(seq_along(x)),
    y2 = as.numeric(x + rnorm(n = n))
  )

  result1 = score(df, 'x', 'y1', verbose = FALSE)
  result2 = score(df, 'x', 'y2', verbose = FALSE)

  expect_equal(result1$model_type, 'regression')
  expect_equal(result1$model_type, 'regression')
})



test_that("Scoring functions work as expected", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = as.integer(seq_along(x))
  )
  result = score(df, 'x', 'y1')
  result_predictors = score_predictors(df, 'y1')
  result_df = score_df(df)
  expect_true(is.list(result))
  expect_true(is.data.frame(result_predictors))
  expect_equal(nrow(result_predictors), ncol(df))
  expect_true(is.data.frame(result_df))
  expect_equal(nrow(result_df), ncol(df) ^ 2)
})



test_that("Algorithsm work as expected", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = as.integer(seq_along(x)),
    y2 = x + rnorm(n = n)
  )
  for (algo in names(available_algorithms())){
    expect_true(is.list(score(df, 'x', 'y1', algorithm = algo)))
    expect_true(is.list(score(df, 'x', 'y2', algorithm = algo)))
  }
})


test_that("Evaluation metrics work as expected", {
  set.seed(1)
  n = 100
  x = rnorm(n = n)
  df = data.frame(
    x = x,
    y1 = as.integer(seq_along(x)),
    y2 = x + rnorm(n = n)
  )
  for (eval in names(available_evaluation_metrics())){
    metrics = list(regression = eval, classification = eval)
    expect_true(is.list(score(df, 'x', 'y1', metrics = metrics)))
    expect_true(is.list(score(df, 'x', 'y2', metrics = metrics)))
  }
})
