{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Handler.HomeSpec (spec) where

import TestImport
import Yesod.Form.Fields

spec :: Spec
spec = withApp $ do

  describe "Homepage" $ do
    it "loads the index and checks it looks right" $ do
      get HomeR
      statusIs 200
      htmlAnyContain "h1" "Welcome to SnamBlog"
      statusIs 200

    it "shows latest posts" $ do
      now <- liftIO getCurrentTime
      let article = Textarea "# Last Post\n\n\
                    \This is the last post"
          blog = Blog "Last Post" article now
      _ <- runDB $ insert blog

      get HomeR
      statusIs 200
      htmlAnyContain "h1" "Last Post"
