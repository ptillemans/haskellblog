{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Handler.BlogSpec (spec) where

import TestImport

spec :: Spec
spec = withApp $ do
  describe "These tests describe the blog page" $ do
    it "check blog page" $ do
      get BlogR
      statusIs 200
      htmlAnyContain "h1" "Latest Posts"
