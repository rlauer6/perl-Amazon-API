# -*- mode: makefile; -*-

AMAZON_PERLMODULES = \
    Amazon/API.pm.in

AMAZON_API_BOTOCORE_PERLMODULES = \
    Amazon/API/Botocore/Pod.pm.in

AMAZON_API_BOTOCORE_SHAPE_PERLMODULES = \
    Amazon/API/Botocore/Shape/Serializer.pm.in \
    Amazon/API/Botocore/Shape/Utils.pm.in

AMAZON_API_PERLMODULES = \
    Amazon/API/Botocore.pm.in

AMAZON_API_POD_SIMPLE_PERLMODULES = \
    Amazon/API/Pod/Simple/Text.pm.in

AMAZON_API_POD_PERLMODULES = \
    Amazon/API/Pod/Parser.pm.in

GALLMODULES = \
    Amazon/API/Constants.pm \
    Amazon/API/Error.pm \
    Amazon/API/Signature4.pm \
    Amazon/API/Botocore/Shape.pm \
    Amazon/API/Template.pm \
    $(GAMAZON_PERLMODULES) \
    $(GAMAZON_API_BOTOCORE_PERLMODULES) \
    $(GAMAZON_API_BOTOCORE_SHAPE_PERLMODULES) \
    $(GAMAZON_API_POD_SIMPLE_PERLMODULES) \
    $(GAMAZON_API_POD_PERLMODULES)
