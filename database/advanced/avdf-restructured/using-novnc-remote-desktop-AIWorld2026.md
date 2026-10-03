# Use noVNC remote desktop

## Introduction

This lab will show you how to get started with your workshop with a remote desktop session.

Estimated Time: 2 minutes

### Objectives

In this lab, you will:

- Enable fullscreen display of remote desktop session
- Enable remote clipboard integration
- Open the workshop guide from the remote desktop

### Prerequisites

This lab assumes you have:

- Provisioned VM Instance configured with noVNC

## Task 1: Enable Full-screen Display

For seamless desktop integration and to make the best use of your display, perform the following tasks to render your remote desktop session in fullscreen mode.

1. Click on the small gray tab on the middle-left side of your screen to open the control bar.
   ![Open control bar](./images/novnc-fullscreen-1.png " ")

2. Select *Fullscreen* to render the session on your entire screen.
   ![Click full screen](./images/novnc-fullscreen-2.png " ")
   ![Open full screen](./images/novnc-fullscreen-3.png " ")

3. Select the Activities button to find out the applications already installed
   ![Click Activities](./images/click-activities.png " ")
   ![Open full screen](./images/see-activities.png " ")

## Task 2: Enable Copy/Paste from Local to Remote Desktop

During the execution of your labs, you may need to copy text from your *local PC/Mac* to the *remote desktop*, such as commands from the lab guide. While such direct copy/paste isn't supported as you will realize, you may proceed as indicated below to enable an alternative *local-to-remote clipboard* with Input Text Field.

1. Continuing from the last task above, Select the *clipboard* icon
   ![Click clipboard](./images/novnc-clipboard-1.png " ")

2. Copy some text from your local computer as illustrated below and paste it into the clipboard widget, then finally open up the desired application (e.g. Terminal) and paste accordingly using *mouse controls*
   ![Copy text](./images/novnc-clipboard-2.png " ")

   >**Note:** Please make sure you initialize your clipboard with Step 1 shown in the screenshot above before opening the target application in which you intend to paste the text. Otherwise will find the *paste* function in the context menu grayed out when attempting to paste for the first time.

## Task 3: Open Your Workshop Guide

1. If the *Web* browser window(s) is(are) not already open side-by-side, double-click the *Get Started with your Workshop* icon from the remote desktop. This will launch one or two windows depending on the workshop.
   ![Get Started with your Workshop](./images/novnc-launch-get-started-1.png " ")

2. On the left window is your workshop guide and depending on your workshop, you may also have one or two browser tabs loaded with web apps. e.g. Weblogic console, Enterprise Manager Cloud Console, or a relevant application to your workshop such as SQL Developer, JDeveloper, etc.
   ![Workshop guide and sample webapp](./images/novnc-launch-get-started-2.png " ")

You may now **proceed to the next lab**.
