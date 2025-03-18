resource "aws_elastic_beanstalk_application" "volleyball_rental" {
  name        = "volleyball-rental-app"
  description = "Elastic Beanstalk application for Volleyball Rental System"
}

resource "aws_elastic_beanstalk_environment" "volleyball_env" {
  application         = aws_elastic_beanstalk_application.volleyball_rental.name
  name                = "volleyball-env"
  solution_stack_name = "64bit Amazon Linux 2 v4.0.6 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.volleyball_version.name

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_URL"
    value     = "jdbc:mysql://${aws_db_instance.volleyball_rds.endpoint}:3306/volleyball_rental_db?useSSL=false&serverTimezone=Asia/Taipei&characterEncoding=utf-8&allowPublicKeyRetrieval=true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_USERNAME"
    value     = "root"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_PASSWORD"
    value     = "volleyroad2024"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_HOST"
    value     = aws_db_instance.volleyball_rds.endpoint
  }
}

resource "aws_s3_bucket" "beanstalk_source" {
  bucket_prefix = "volleyball-beanstalk-zip-"
  acl           = "private"
}

data "archive_file" "backend_zip" {
  type        = "zip"
  source_dir  = "/Users/innacheng/Desktop/Volleyball-Rental-System-backend"
  output_path = "/Users/innacheng/Desktop/Volleyball-Rental-System-backend/volleyball-backend.zip"
}

resource "aws_s3_bucket_object" "beanstalk_zip" {
  bucket = aws_s3_bucket.beanstalk_source.id
  key    = "volleyball-backend.zip"
  source = data.archive_file.backend_zip.output_path
  exclude     = ["**/mysqld*"]  # Exclude any file or directory named mysqld
}

resource "aws_elastic_beanstalk_application_version" "volleyball_version" {
  application = aws_elastic_beanstalk_application.volleyball_rental.name
  name        = "volleyball-backend"
  bucket      = aws_s3_bucket.beanstalk_source.id
  key         = aws_s3_bucket_object.beanstalk_zip.key
}
