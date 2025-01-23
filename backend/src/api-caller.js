import qs from 'qs'
import * as crypto from 'node:crypto'
import axios from 'axios'

const TUYA_HOST = process.env.TUYA_HOST
const TUYA_ACCESS_KEY = process.env.TUYA_ACCESS_KEY
const TUYA_SECRET_KEY = process.env.TUYA_SECRET_KEY

if (!TUYA_HOST || !TUYA_ACCESS_KEY || !TUYA_SECRET_KEY) {
    console.error('Missing tuya variables',)
    process.exit(1)
}


const httpClient = axios.create({
  baseURL: TUYA_HOST,
  timeout: 5 * 1e3,
});

let token = '';
async function getToken() {
  const method = 'GET';
  const timestamp = Date.now().toString();
  const signUrl = '/v1.0/token?grant_type=1';
  const contentHash = crypto.createHash('sha256').update('').digest('hex');
  const stringToSign = [method, contentHash, '', signUrl].join('\n');
  const signStr = TUYA_ACCESS_KEY + timestamp + stringToSign;

  const headers = {
    t: timestamp,
    sign_method: 'HMAC-SHA256',
    client_id: TUYA_ACCESS_KEY,
    sign: await encryptStr(signStr, TUYA_SECRET_KEY),
  };
  const { data: login } = await httpClient.get('/v1.0/token?grant_type=1', { headers });
  if (!login || !login.success) {
    throw Error(`fetch failed: ${login.msg}`);
  }
  token = login.result.access_token;
}


async function encryptStr(str, secret) {
  return crypto.createHmac('sha256', secret).update(str, 'utf8').digest('hex').toUpperCase();
}

/**
 * request sign, save headers 
 * @param path
 * @param method
 * @param headers
 * @param query
 * @param body
 */
async function getRequestSign(
  path,
  method,
  headers = {},
  query= {},
  body= {},
) {
  const t = Date.now().toString();
  const [uri, pathQuery] = path.split('?');
  const queryMerged = Object.assign(query, qs.parse(pathQuery));
  const sortedQuery = {};
  Object.keys(queryMerged)
    .sort()
    .forEach((i) => (sortedQuery[i] = query[i]));

  const querystring = decodeURIComponent(qs.stringify(sortedQuery));
  const url = querystring ? `${uri}?${querystring}` : uri;
  const contentHash = crypto.createHash('sha256').update(JSON.stringify(body)).digest('hex');
  const stringToSign = [method, contentHash, '', url].join('\n');
  const signStr = TUYA_ACCESS_KEY + token + t + stringToSign;
  return {
    t,
    path: url,
    client_id: TUYA_ACCESS_KEY,
    sign: await encryptStr(signStr, TUYA_SECRET_KEY),
    sign_method: 'HMAC-SHA256',
    access_token: token,
  };
}

function parseCategory(category) {
    switch (category) {
        case 'tdq':
            return 'switch'
        case 'clkg':
            return 'curtain'
        case 'kg':
            return 'triple-switch'
    }
    return null
}

function parseDeviceStatus(status) {
    
    const percentage_value = status.find(e => e.code === 'percent_control')?.value
    if (percentage_value != null) {
        return percentage_value
    }
    const switch1 = status.find(e => e.code === 'switch_1')?.value
    const switch2 = status.find(e => e.code === 'switch_2')?.value
    const switch3 = status.find(e => e.code === 'switch_3')?.value

    if (switch1 != null && switch2 != null && switch3 != null) {
        return [switch1, switch2, switch3]
    }

    if (switch1 != null) {
        return switch1
    }
  return {unknown: 'failed to parse device status', raw: status}
}

export async function getDeviceStatus(deviceId){
    await getToken();
  
    const body = { }
  const query = {};
  const method = "GET";
  const url = `/v1.0/devices/${deviceId}/status`;
  const reqHeaders = await getRequestSign(
    url,
    method,
    {},
      query,
      body,
  );

  const { data } = await httpClient.request({
    method,
    data: body,
    params: {},
    headers: reqHeaders,
    url: reqHeaders.path,
  });
  if (!data || !data.success) {
    throw Error(`request api failed: ${data.msg}`);
  }
    
    return parseDeviceStatus(data.result)

}

export async function sendCommandToDevice(deviceId, code, value) {
    await getToken()
    const body = { commands: [{code, value}]}
const query = {};
  const method = "POST";
  const url = `/v1.0/devices/${deviceId}/commands`;
  const reqHeaders = await getRequestSign(
    url,
    method,
    {},
      query,
      body,
  );

  const { data } = await httpClient.request({
    method,
    data: body,
    params: {},
    headers: reqHeaders,
    url: reqHeaders.path,
  });
  if (!data || !data.success) {
    throw Error(`request api failed: ${data.msg}`);
  }
}


export async function getDevicesList(homeId) {
    await getToken()
    const body = {}
const query = {};
  const method = "GET";
  const url = `/v1.0/homes/${homeId}/devices`;
  const reqHeaders = await getRequestSign(
    url,
    method,
    {},
      query,
      body,
  );

  const { data } = await httpClient.request({
    method,
    data: body,
    params: {},
    headers: reqHeaders,
    url: reqHeaders.path,
  });
  if (!data || !data.success) {
    throw Error(`request api failed: ${data.msg}`);
  }
    const { result } = data
    
    return result.map(device => ({
        id: device.id,
        name: device.name,
        status: parseDeviceStatus(device.status),
        category: parseCategory(device.category),
    })).filter(e => !!e.category)
}