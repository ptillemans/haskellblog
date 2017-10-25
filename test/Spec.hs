{-# OPTIONS_GHC -F -pgmF hspec-discover #-}
import TestImport

homeSpecs :: Spec
homeSpecs =
  yDescribe "These tests describe the home page" $ do

    yit "check friendly title message" $ do
      get HomeR
      statusIs 200
      htmlAnyContain "h2" "Welcome to SnamBlog"

blogSpecs :: Spec
blogSpecs =
  yDescribe "These tests describe the blog page" $ do
  yit "check blog page" $ do
    get BlogR
    statusIs 200
    htmlAnyContain "h2" "Latest Posts"
