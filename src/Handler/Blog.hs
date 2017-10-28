{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Blog where

import Import

getBlogR :: Handler Html
getBlogR = do
  defaultLayout $ do
    setTitle "Latest Post on the Blog"
    $(widgetFile "blog")

postBlogR :: Handler Value
postBlogR = do
  blog <- (requireJsonBody :: Handler Blog)

  maybeCurrentUserId <- maybeAuthId
  let blog' = blog { blogUserId = maybeCurrentUserId }

  insertedBlog <- runDB $ insertEntity blog'
  returnJson insertedBlog
