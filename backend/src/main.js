import express from 'express'

import { getDevicesList, getDeviceStatus, sendCommandToDevice } from './api-caller.js'

if (!process.env.HOME_ID) {
    console.error('Missing HOME_ID env variable')
    process.exit(1)
}

const app = express()
app.use(express.json());
app.use((req, res, next) => {
    const token = req.header('authorization')?.split?.(' ')?.[1]
    if (token !== process.env.TOKEN || !process.env.TOKEN) return res.sendStatus(401)
    next()
})
function wrapWithHandler(next) {
    return async (...args) => {
        try {
            await next(...args)
        } catch (e) {
            console.error(e)
            const [,res] = args
            res.end();
        }
    }
}
app.listen(+process.env.PORT || 3000)

app.get('/devices', wrapWithHandler(async (req, res) => {
    const devices = await getDevicesList(process.env.HOME_ID)

    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify({
        devices
    }))
}))

app.get('/device/:deviceId/status', wrapWithHandler(async (req, res) => {
    const status = await getDeviceStatus(req.params.deviceId)

    res.setHeader('Content-Type', 'application/json')
    res.end(JSON.stringify(
        status
    ))
}))

app.post('/device/:deviceId/command/:code/:action', wrapWithHandler(async (req, res) => {
    await sendCommandToDevice(req.params.deviceId, req.params.code, req.params.action)

    res.sendStatus(204)
}))