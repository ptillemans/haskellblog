{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Handler.Blog where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import Text.Markdown (markdown, defaultMarkdownSettings)

blogIds :: (Text, Text)
blogIds = ("article-form", "article-submit")

data BlogForm = BlogForm {
  title :: Text,
  article :: Textarea,
  posted :: UTCTime
}

blogForm :: Form BlogForm
blogForm = renderBootstrap3 BootstrapBasicForm $ BlogForm
  <$> areq textField "Title" Nothing
  <*> areq textareaField taSettings Nothing
  <*> lift(liftIO getCurrentTime)
  where
    taSettings = FieldSettings
      "Article"
      Nothing
      Nothing
      Nothing
      [("rows", "20"),
      ("cols", "80")]


getBlogR :: Handler Html
getBlogR = do
  (formWidget, formEnctype) <- generateFormPost blogForm
  blogs <- runDB $ selectList
    [BlogArticle !=. Textarea ""]
    [LimitTo 3, Desc BlogPosted]
  let markdownSettings = defaultMarkdownSettings

  defaultLayout $ do
    let (blogFormId, articleSubmitId) = blogIds
    setTitle "Latest Post on the Blog"
    $(widgetFile "blog")

postBlogR :: Handler Html
postBlogR = do
  ((result, formWidget), formEnctype) <- runFormPost blogForm
  blogs <- runDB $ selectList [BlogArticle !=. Textarea ""] [LimitTo 3]
  let markdownSettings = defaultMarkdownSettings

  let (blogFormId, articleSubmitId) = blogIds
  case result of
    FormSuccess blog -> do
      _ <- runDB $ insert $
        Blog (title blog) (article blog) (posted blog)
      defaultLayout $ do
        setTitle "Latest Post on the Blog"
        $(widgetFile "blog")
    _ -> do
      _ <- setMessage "<p>Invalid Input<p>"
      defaultLayout $ do
        setTitle "Latest Post on the Blog"
        $(widgetFile "blog")

dateFormat :: UTCTime -> String
dateFormat = formatTime defaultTimeLocale "%F"


getArticleR :: BlogId -> Handler Html
getArticleR blogId = do
  blog <- runDB $ get404 blogId
  let markdownSettings = defaultMarkdownSettings
      title = blogTitle blog
      posted = dateFormat $ blogPosted blog
      article = markdown markdownSettings $ fromStrict $ unTextarea $ blogArticle blog
  defaultLayout $ do
    setTitle $ toHtml title
    $(widgetFile "article")

putArticleR :: BlogId -> Handler Html
putArticleR blogId = undefined

deleteArticleR :: BlogId -> Handler Html
deleteArticleR blogId = undefined
