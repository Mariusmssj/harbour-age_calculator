# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-age_calculator

CONFIG += sailfishapp

SOURCES += src/harbour-age_calculator.cpp

OTHER_FILES += qml/harbour-age_calculator.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-age_calculator.spec \
    rpm/harbour-age_calculator.yaml \
    harbour-age_calculator.desktop

