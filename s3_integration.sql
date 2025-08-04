CREATE STAGE my_s3_stage
  STORAGE_INTEGRATION = s3_int
  URL = 's3://mybucket/encrypted_files/'
  FILE_FORM››AT = my_csv_format;