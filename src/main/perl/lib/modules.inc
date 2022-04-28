# -*- mode: makefile; -*-

AMAZON_PERLMODULES = \
    Amazon/API.pm.in

AMAZON_API_BOTOCORE_PERLMODULES = \
    Amazon/API/Botocore/Pod.pm.in

AMAZON_API_PERLMODULES = \
    Amazon/API/Botocore.pm.in \
    Amazon/API/CloudWatchLogs.pm.in \
    Amazon/API/EC2.pm.in \
    Amazon/API/ECR.pm.in \
    Amazon/API/ECS.pm.in \
    Amazon/API/SQS.pm.in \
    Amazon/API/SSM.pm.in \
    Amazon/API/STS.pm.in \
    Amazon/API/SecretsManager.pm.in

GALLMODULES = \
    Amazon/API/Constants.pm \
    Amazon/API/Error.pm \
    Amazon/API/Signature4.pm \
    $(GAMAZON_PERLMODULES) \
    $(GAMAZON_API_PERLMODULES) \
    $(GAMAZON_API_BOTOCORE_PERLMODULES)

