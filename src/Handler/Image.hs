{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Handler.Image where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import qualified Database.MongoDB.GridFS as GFS
import Data.Aeson
import Data.Text as T
import Database.MongoDB (select, (=:))

data ImageUploadForm = ImageUploadForm {
  formFile :: FileInfo
}

imageUploadIds :: (Text, Text)
imageUploadIds = ("upload-form", "upload-submit")

imageUploadForm :: Form ImageUploadForm
imageUploadForm = renderBootstrap3 BootstrapBasicForm $ ImageUploadForm
  <$> areq fileField FieldSettings { fsLabel = "Image"
                                   , fsTooltip = Just "Select the file to upload"
                                   , fsId = Just "image"
                                   , fsName = Just "image"
                                   , fsAttrs = [] } Nothing

getImageR :: Text -> Handler TypedContent
getImageR imageId = do
  mfile <- runDB $ do
    bucket <- GFS.openDefaultBucket
    GFS.findOneFile bucket ["filename" =: imageId]
  source <- case mfile of
    Just file -> return $ transPipe runDB (GFS.sourceFile file)
    Nothing -> return $ return ()
  respondSource "image/jpeg" $ source .| awaitForever sendChunkBS




deleteImageR :: Text  -> Handler Html
deleteImageR imageId = error "Not yet implemented: deleteImageR"

getImageUploadR :: Handler Html
getImageUploadR = trace "getImageUploadR" $ do
  (formWidget, formEnctype) <- generateFormPost imageUploadForm
  defaultLayout $ do
    let (uploadFormId, uploadSubmitId) = imageUploadIds
    setTitle "Upload an Image"
    $(widgetFile "imageUpload")

postImageUploadHtml :: Handler Html
postImageUploadHtml = trace "postImageUploadHtml" $ do
  ((result, formWidget), formEnctype) <- runFormPost imageUploadForm
  let (uploadFormId, uploadSubmitId) = imageUploadIds
  case result of
    FormSuccess upload -> uploadFile upload
    _                  -> setMessage "<p>Invalid Input</p>"
  defaultLayout $ do
    setTitle "Upload an Image"
    $(widgetFile "imageUpload")
  where
    uploadFile upload = runDB $ trace "uploading image" $ do
        bucket <- GFS.openDefaultBucket
        let file = formFile upload
        runConduit $ fileSource file .| GFS.sinkFile bucket (fileName file)
        liftIO $ putStrLn "file uploaded"

postImageUploadJson :: Handler Value
postImageUploadJson = trace "postImageUploadJson" $ do
  ((result, formWidget), formEnctype) <- runFormPostNoToken imageUploadForm
  case result of
    FormSuccess upload -> do
      uploadFile upload
      return $ object [ "filename" .= ("/image/" <> (fileName . formFile $ upload)) ]
    FormMissing ->  trace "form missing" $ return $ object [ "filename" .= (T.pack "missing-file") ]
    FormFailure ss -> trace (T.unpack . T.concat $ ss) $ return $ array ss
  where
    uploadFile upload = runDB $ trace "uploading image" $ do
        bucket <- GFS.openDefaultBucket
        let file = formFile upload
        runConduit $ fileSource file .| GFS.sinkFile bucket (fileName file)
        liftIO $ putStrLn "file uploaded"


postImageUploadR :: Handler TypedContent
postImageUploadR =  selectRep $ do
  provideRep $ postImageUploadHtml
  provideRep $ postImageUploadJson
