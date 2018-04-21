{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Handler.Blog where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import Yesod.Core.Handler (defaultCsrfHeaderName, defaultCsrfCookieName)
import Text.Markdown (markdown, defaultMarkdownSettings)
import Data.CaseInsensitive as CI
import Data.Text.Encoding as TE
import Text.Julius (rawJS, RawJavascript)

blogIds :: (Text, Text)
blogIds = ("article-form", "article-submit")

data BlogForm = BlogForm {
  formTitle :: Text,
  formArticle :: Textarea,
  formPosted :: UTCTime
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

csrfHeaderName :: RawJavascript
csrfHeaderName =
  rawJS $ TE.decodeUtf8 $ CI.foldedCase defaultCsrfHeaderName

csrfCookieName :: RawJavascript
csrfCookieName =
  rawJS $ TE.decodeUtf8 $ defaultCsrfCookieName

getBlogR :: Handler Html
getBlogR = do
  (formWidget, formEnctype) <- generateFormPost blogForm
  defaultLayout $ do
    let (blogFormId, articleSubmitId) = blogIds
    let hname = csrfHeaderName
    let cname = csrfCookieName
    setTitle "Create a new Post"
    addStylesheetRemote "https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css"
    addScriptRemote "https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js"
    addScript $ StaticR js_inlineattachment_js
    addScript $ StaticR js_codemirror4inlineattachment_js
    $(widgetFile "blog")

postBlogR :: Handler Html
postBlogR = do
  ((result, formWidget), formEnctype) <- runFormPost blogForm
  let hname = csrfHeaderName
  let cname = csrfCookieName
  let (blogFormId, articleSubmitId) = blogIds
  case result of
    FormSuccess blog -> do
      _ <- runDB $ insert $
        Blog (formTitle blog) (formArticle blog) (formPosted blog)
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
