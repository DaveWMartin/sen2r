context("Test gdal_warp()")

crop_poly <- system.file("extdata/vector/dam.geojson", package = "sen2r")
crop_line <- sf::st_cast(sf::read_sf(crop_poly), "LINESTRING")
test1 <- tempfile(fileext = "_test1.tif")
ex_sel <- system.file(
  "extdata/out/S2A2A_20190723_022_Barbellino_RGB432B_10.tif", 
  package = "sen2r"
)
ex_ref <- system.file(
  "extdata/out/S2A2A_20190723_022_Barbellino_SCL_10.tif", 
  package = "sen2r"
)

testthat::test_that(
  "Simple clip", {
    
    gdal_warp(ex_sel, test1, mask = crop_line)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test1, format = "list")[[1]]
    testthat::expect_equal(names(exp_meta_r), c(
      "path", "valid", "res", "size", "nbands", "bbox", "proj", "unit", "outformat", "type"
    ))
    testthat::expect_equal(exp_meta_r$size, c("x"=8, "y"=26))
    testthat::expect_equal(exp_meta_r$res, c("x"=10, "y"=10))
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(580620, 5101790, 580700, 5102050)
    )
    expect_equal_crs(exp_meta_r$proj, 32632)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test1)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 97.15385, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 0)
    rm(exp_stars)
    
    # tests on sen2r metadata
    exp_meta_s <- testthat::expect_error(
      sen2r_getElements(test1),
      regexp = "not[ \n]recognised"
    )
    
  }
)

testthat::test_that(
  "Clip and mask", {
    
    test2 <- tempfile(fileext = "_test2.tif")
    gdal_warp(ex_sel, test2, mask = crop_poly)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test2, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=8, "y"=26))
    testthat::expect_equal(exp_meta_r$res, c("x"=10, "y"=10))
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(580620, 5101790, 580700, 5102050)
    )
    expect_equal_crs(exp_meta_r$proj, 32632)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test2)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 109.8916, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 125, tolerance = 1e-03)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Clip and mask", {
    
    test3 <- tempfile(fileext = "_test3.tif")
    gdal_warp(ex_sel, test3, ref = ex_ref)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test3, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=12, "y"=21))
    testthat::expect_equal(exp_meta_r$res, c("x"=20, "y"=20))
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(580560, 5101700, 580800, 5102120)
    )
    expect_equal_crs(exp_meta_r$proj, 32632)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test3)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 77.44048, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 0)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Reproject all the input file", {
    
    test4 <- tempfile(fileext = "_test4.tif")
    gdal_warp(ex_sel, test4, t_srs = 32631)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test4, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=27, "y"=44))
    testthat::expect_equal(exp_meta_r$res, c("x"=10.07, "y"=9.97), tolerance = 1e-3)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044533, 5125330, 1044805, 5125769),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test4)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 76.87846, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 176, tolerance = 1e-3)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Reproject in a projection without EPSG", {
    # this test is intended to test gdal_warp() passing a WKT to gdalwarp
    # instead then the EPSG code
    
    modis_wkt <- paste0(
      'PROJCS["Sinusoidal",GEOGCS["GCS_Undefined",DATUM["Undefined",SPHEROID[',
      '"User_Defined_Spheroid",6371007.181,0.0]],PRIMEM["Greenwich",0.0],UNIT',
      '["Degree",0.0174532925199433]],PROJECTION["Sinusoidal"],PARAMETER["Fal',
      'se_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Me',
      'ridian",0.0],UNIT["Meter",1.0]]'
    )
    test4b <- tempfile(fileext = "_test4b.tif")
    test4_out <- tryCatch(
      gdal_warp(ex_sel, test4b, t_srs = modis_wkt),
      warning = function(w) {
        suppressWarnings(gdal_warp(ex_sel, test4b, t_srs = modis_wkt))
        w$message
      }
    )
    testthat::expect_true(any(
      test4_out == 0,
      grepl("Discarded datum unknown in CRS definition", test4_out)
    ))
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test4b, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=27, "y"=40))
    testthat::expect_equal(exp_meta_r$res, c("x"=10.64168, "y"=10.58520), tolerance = 1e-3)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(774691.9, 5122100.0,  774979.2, 5122523.4),
      tolerance = 1e-3
    )
    testthat::expect_equal(exp_meta_r$proj$epsg, as.integer(NA))
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test4b)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 76.77778, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 180, tolerance = 1e-3)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Reproject and clip on a bounding box", {
    
    test5 <- tempfile(fileext = "_test5.tif")
    gdal_warp(
      ex_sel, test5, 
      t_srs = "EPSG:32631", 
      mask = stars::read_stars(test1)
    )
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test5, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=10, "y"=27))
    testthat::expect_equal(exp_meta_r$res, c("x"=9.98, "y"=9.86), tolerance = 1e-3)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044599, 5125425, 1044698, 5125691),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test5)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 97.21495, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 56, tolerance = 1e-03)
    rm(exp_stars)
    
  }
)

test6 <- tempfile(fileext = "_test6.tif")
testthat::test_that(
  "Reproject and clip on polygon (masking outside)", {
    
    gdal_warp(
      ex_sel, test6, 
      t_srs = 32631, 
      mask = crop_poly
    )
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test6, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=6, "y"=25))
    testthat::expect_equal(exp_meta_r$res, c("x"=10.7, "y"=10.2), tolerance = 1e-2)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044599, 5125425, 1044698, 5125691),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test6)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 110.5455, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 73, tolerance = 1e-03)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Use a reference raster with a different projection", {
    
    test7 <- tempfile(fileext = "_test7.tif")
    gdal_warp(ex_sel, test7, ref = test6)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test7, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x" = 6, "y" = 25))
    testthat::expect_equal(
      exp_meta_r$res, c("x" = 10.67998, "y" = 10.21008),
      tolerance = 1e-3
    )
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044599, 5125425, 1044698, 5125691),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test7)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 91.76, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 0)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "...and specify a different bounding box", {
    
    test8 <- tempfile(fileext = "_test8.tif")
    gdal_warp(ex_sel, test8, mask = stars::read_stars(test1), ref = test6)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test8, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=9, "y"=26))
    testthat::expect_equal(exp_meta_r$res, c("x"=10.67998, "y"=10.21008 ), tolerance = 1e-3)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044599, 5125425, 1044698, 5125691),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test8)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 94.52093, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 19, tolerance = 1e-03)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Use a reference raster with a different projection and a mask", {
    
    test9 <- tempfile(fileext = "_test9.tif")
    gdal_warp(ex_sel, test9, mask = crop_poly, ref = test6)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test9, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=6, "y"=25))
    testthat::expect_equal(exp_meta_r$res, c("x"=10.67998, "y"=10.21008 ), tolerance = 1e-3)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044599, 5125425, 1044698, 5125691),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test9)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 100.1134, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 53, tolerance = 1e-03)
    rm(exp_stars)
    
  }
)

testthat::test_that(
  "Clip, mask and reproject", {
    
    test10 <- tempfile(fileext = "_test10.tif")
    gdal_warp(ex_sel, test10, mask = crop_poly, t_srs = 32631)
    
    # test on raster metadata
    exp_meta_r <- raster_metadata(test10, format = "list")[[1]]
    testthat::expect_equal(exp_meta_r$size, c("x"=6, "y"=25))
    testthat::expect_equal(exp_meta_r$res, c("x"=10.68, "y"=10.21), tolerance = 1e-3)
    testthat::expect_equal(exp_meta_r$nbands, 3)
    testthat::expect_equal(
      as.numeric(exp_meta_r$bbox), 
      c(1044614, 5125427, 1044678, 5125683),
      tolerance = 1e-3
    )
    expect_equal_crs(exp_meta_r$proj, 32631)
    testthat::expect_equal(exp_meta_r$type, "Byte")
    testthat::expect_equal(exp_meta_r$outformat, "GTiff")
    
    # test on raster values
    exp_stars <- stars::read_stars(test10)
    testthat::expect_equal(mean(exp_stars[[1]][,,3], na.rm=TRUE), 110.5455, tolerance = 1e-03)
    testthat::expect_equal(sum(is.na(exp_stars[[1]][,,3])), 73, tolerance = 1e-03)
    rm(exp_stars)
    
  }
)


# context("Test conversion from/to VRT with relative paths to/from VRT with absolute paths")
# testthat::skip_on_cran()
# testthat::skip_on_travis()
# 
# abs_file <- exp_outpath_4
# rel_file <- file.path(tempdir(), "S2A2A_20190723_022_Scalve_SCL_10_rel.vrt")
# testthat::test_that(
#   "Tests on gdal_abs2rel()", {
#     
#     testthat::expect_true(dir.exists(outdir_4))
#     testthat::expect_true(file.exists(abs_file))
#     
#     abs_content <- readLines(abs_file)
#     abs_path <- gsub(
#       "^.* relativeToVRT=\"0\">(.*)</.*", "\\1",
#       abs_content[grepl("relativeToVRT", abs_content)]
#     )
#     testthat::expect_true(grepl("^/", abs_path))
#     
#     gdal_abs2rel(abs_file, out_vrt = rel_file)
#     testthat::expect_true(file.exists(rel_file))
#     
#   }
# )
#     
# 
# testthat::test_that(
#   "Tests on gdal_rel2abs()", {
#     
#     rel_content <- readLines(rel_file)
#     rel_path <- gsub(
#       "^.* relativeToVRT=\"1\">(.*)</.*", "\\1",
#       rel_content[grepl("relativeToVRT", rel_content)]
#     )
#     testthat::expect_true(grepl("^\\.\\.?/", rel_path))
#     
#     oldwd <- getwd()
#     setwd(dirname(abs_file))
#     testthat::expect_true(file.exists(rel_path))
#     gdal_rel2abs(rel_file)
#     testthat::expect_true(file.exists(rel_file))
#     
#     abs_content <- readLines(rel_file)
#     abs_path <- gsub(
#       "^.* relativeToVRT=\"0\">(.*)</.*", "\\1",
#       abs_content[grepl("relativeToVRT", abs_content)]
#     )
#     testthat::expect_true(grepl("^/", abs_path))
#     setwd(oldwd)
#     
#   }
# )
