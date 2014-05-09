context("NBLAST v2")

testneurons <- readRDS('testdata/testneurons.rds')

test_that("nblast v1 produces expected scores", {
  scores <- nblast(testneurons[[1]], testneurons, version='2')
  scores.expected <- structure(c(22393.1456610767, -33103.620929615, -35603.5457297204, -18717.4612913414, -35799.9999942706), .Names = c("5HT1bMARCM-F000001_seg001", "5HT1bMARCM-F000002_seg001", "5HT1bMARCM-F000003_seg001", "5HT1bMARCM-F000004_seg001", "5HT1bMARCM-F000005_seg001"))
  expect_equal(scores, scores.expected)
})

test_that("nblast v1 with alpha produces expected scores", {
  scores <- nblast(testneurons[[1]], testneurons, version='2', UseAlpha=TRUE)
  scores.expected <- structure(c(22393.1456610767, -33103.620929615, -35603.5457297204, -18717.4612913414, -35799.9999942706), .Names = c("5HT1bMARCM-F000001_seg001", "5HT1bMARCM-F000002_seg001", "5HT1bMARCM-F000003_seg001", "5HT1bMARCM-F000004_seg001", "5HT1bMARCM-F000005_seg001"))
  expect_equal(scores, scores.expected)
})