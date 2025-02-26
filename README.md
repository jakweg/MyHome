# Home app for Garmin

##### The app allows You to use Your Garmin watch to control Tuya IoT devices such as switches, lights and blinds.

## Interested in how it works? See [the Reddit post](https://www.reddit.com/r/Garmin/comments/1ixxews/i_coded_iot_controller_app_for_my_garmin/)

## How to use it?

**This setup requires technical knowledge**. For now in order to use it you need to host your backend. The backend can be hosted on any VPS with a domain name and HTTPS. Since it's a docker that doesn't need persistance you can use solutions such as `Cloud Run` as well.

#### Tuya Developer Account setup

You're going to need to have IoT devices connected Tuya platform. Create a developer account on [Tuya website](https://platform.tuya.com/cloud/basic). You may need to choose a plan, the free one is more than enough, no need to give any credit card information. The create a new project and save `Access ID/Client ID` as well as `Access Secret/Client Secret`. Then in `devices` tab use `Link App Account` section to add Your Tuya account to the developer account. Thanks to that you now can access devices from the website. Save the `UID` value of Your account. Navigate to `Cloud` -> `Api Explorer` -> Change `IoT Core` to `Smart Home Basic Service` -> `Home Management` -> `Query Home List` -> Paste your `uid` and see `Debugging results`. There is `home_id`, save it.

#### Backend setup

Clone this repo and change directory to `backend`. Copy `example.env` to `.env` and fill the details using the info you got from the previous step. Use some arbitrary number for `PORT` and set up a reverse proxy for that. If you're using cloud solution such as `Cloud Run` it's done for You. Execute `docker-compose up` and check if the API responds with a status of 401 - it should be.

#### Garmin App Build

Open `garmin` folder in VSCode. Open `Secrets.mc` file and modify its content to point to your domain and with Your API Token. Make sure not to commit this file, for example use `git update-index --assume-unchanged Secrets.mc`.  Install `Monkey C` extension and press `CRTL/CMD+P` and type `> build`. Choose `Build for Device`. You might change your device in `manifest.xml` first if you're using different device then `Forerunner 965`. Once a successful build is done. You should see `garmin.prg` file in your build directory.

#### Install the App on Your watch

Connect your watch to the PC via cable and open it as a pendrive. Now go to `Garmin/Apps` folder and paste here the `garmin.prg` file you got in a previous step. Disconnect your device.

#### Sync and hide devices

Every time you do any change to the list of devices (eg. buy a new one) you need to press Menu inside the app and choose `Sync devices`, then reopen the app. You may also hide devices you're not using using the second option.




