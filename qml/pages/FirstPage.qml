/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql

Page {
    id: page
    property var today: new Date()  //todays date
    property var usrDate: new Date()//date that the user has picked
    property int daysInMonth: new Date(usrDate.year, usrDate.month, 0).getDate()
    property var age: 0             //Users age in years
    property var months: 0          //Users age in months
    property var days: 0            //Users age in days
    property var totalMonths: 0
    property var totalWeeks: 0
    property var totalDays: 0
    property var totalHours: 0
    property var totalMinutes: 0
    property string lSavedDate: ""

    function calcAge() // Function to calculate the age
    {
        age = today.getFullYear() - usrDate.year
        if((today.getMonth()+1) < usrDate.month || ((today.getMonth()+1) === usrDate.month && today.getDate() < usrDate.day))
            age = age - 1

        months = (today.getMonth()+1) - usrDate.month
        if((months == 0) && (today.getDate() < usrDate.day))
            months = 11;
        else if((today.getMonth()+1) < usrDate.month)
        {
            months = (today.getMonth()+13) - usrDate.month
            //console.log("1__ Months calc: ", months )
        }

        days = today.getDate() - usrDate.day
        //console.log("DAYS: ", days )
        //console.log("days in month ",  daysInMonth)
        if(today.getDate() < usrDate.day)
        {
            days = daysInMonth + days
            if((today.getMonth()+1) - usrDate.month != 0)
                months = today.getMonth()
            //console.log("2__ Months calc: ", months)
            if((today.getMonth()+1) !== usrDate.month)
                months = today.getMonth() - usrDate.month
                //console.log("3__ Months calc: ", months)}
            if((today.getMonth()+1) < usrDate.month)
                months = (today.getMonth()+12) - usrDate.month
                //console.log("4__ Months calc: ", months)}
        }

        totalMonths = (age * 12) + months;
        totalWeeks = totalMonths * 4.34812;
        totalDays = (totalMonths * 30.4368) + days;
        totalHours = totalDays * 24;
        totalMinutes = totalHours * 60;
    }


    function getSavedDate()
    {
        var db = Sql.LocalStorage.openDatabaseSync("UserDate", "1.0", "Stores last users date", 1);

        //create table
        db.transaction(function(tx)
        {
            var query = 'CREATE TABLE IF NOT EXISTS SavedDate(Year INTEGER , Month INTEGER , Day INTEGER)';
            tx.executeSql(query);
        });
        return db;
    }

    function cleanDb() {
        var db = Sql.LocalStorage.openDatabaseSync("UserDate", "1.0", "Stores last users date", 1);
        db.transaction(
                    function(tx) {
                        tx.executeSql("DROP TABLE IF EXISTS SavedDate");}
                    );
    }

    function deleteTable() {
        var db = Sql.LocalStorage.openDatabaseSync("UserDate", "1.0", "Stores last users date", 1);
        db.transaction(
                    function(tx) {
                        tx.executeSql("DELETE FROM SavedDate");}
                    );
    }

    function saveDate()
    {
        var db = getSavedDate();

        db.transaction(function(tx)
        {
            var rs = tx.executeSql("INSERT OR REPLACE INTO SavedDate VALUES (?,?,?)", [usrDate.year, usrDate.month, usrDate.day]);
        });
    }

    function loadSavedDate(choice)
    {
        var db = getSavedDate()

        db.transaction(function(tx)
        {
            var rs = tx.executeSql('SELECT * FROM SavedDate');
            var dbItem = rs.rows.item(0);
            usrDate.year = dbItem.Year
            usrDate.month = dbItem.Month
            usrDate.day = dbItem.Day
        });
        if(choice === 1)
            button.text = "You chose: " + usrDate.year + " / " + usrDate.month + " / " + usrDate.day
        if(choice === 2)
            lSavedDate = usrDate.year + " / " + usrDate.month + " / " + usrDate.day

        daysInMonth = new Date(usrDate.year, usrDate.month, 0).getDate()
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: "Load last picked date: " + lSavedDate
                onClicked: {
                    loadSavedDate(1)
                    calcAge()
                }
            }

            MenuItem {
                text: "Pick a new date"
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                           date: new Date() //uses today date by default
                                                       })
                           dialog.accepted.connect(function() {
                               usrDate = dialog
                               button.text = "You chose: " + dialog.dateText
                               lSavedDate = dialog.year + " / " + dialog.month + " / " + dialog.day
                               calcAge()
                               saveDate()
                               deleteTable()
                               saveDate()
                           })
                       }
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        Column {
            id: column
            width: page.width
            anchors.fill: parent
            spacing: Theme.paddingLarge
            Component.onCompleted: loadSavedDate(2)
            PageHeader {
                title: "Age Calculator"
            }

            Label{ //shows todays date
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                anchors.left: parent.left
                anchors.leftMargin: 20
                text: "Today's date: " + today.getFullYear() + " / " + (today.getMonth()+1) + " / " + today.getDate()
            }

            Button { //Asks user to pick a date
                id: button
                text: "Choose a Date of Birth"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                    date: new Date() //uses today date by default
                                                })
                    dialog.accepted.connect(function() {
                        usrDate = dialog
                        button.text = "You chose: " + dialog.dateText
                        lSavedDate.text = dialog.year + " / " + dialog.month + " / " + dialog.day
                        calcAge()
                        saveDate()
                        deleteTable()
                        saveDate()
                    })
                }
            }

            Label{ //Displays age in years
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge + 5
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 22
                text: age + " Years " + months + " months " + days + " days"
            }

            SectionHeader { text: "Totals in: " }

            Label{
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: totalMonths.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " months and " + days + " days"
            }
            Label{
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: totalWeeks.toFixed(0).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " weeks and " + days + " days"
            }
            Label{
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: totalDays.toFixed(0).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " days"
            }
            Label{
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: totalHours.toFixed(0).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " hours"
            }
            Label{
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: totalMinutes.toFixed(0).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " minutes"
            }

        }
    }
}
