import axios from 'axios';

const convertParamToUrl = param => {
  if (window.location.protocol !== 'file:') {
    return param
  }
  return '/' + decodeURIComponent(
    param
      .replace(window.location.href
        .replace('index.html', '')
        .split('?inertia-url=')[0], ''
      )
      .replace('?inertia-url=', '')
      .replace('index.html', '')) || '/'
}

window.history.replaceState = function () {
  return;
};

window.history.pushState = function () {
  return;
};

const getFakeError = config => {
  const mockError = new Error();
  mockError.response = {
    data: { "component": "App", "props": {}, "url": "/", "version": "" },
    status: 200,
    statusText: 'OK'
  };
  mockError.config = config;
  return Promise.reject(mockError);
};

const isFakeError = error => Boolean(error.response);

let handleInertiaEvent;

const getResponseFromEvent = async (mockError) => {
  const { config } = mockError;
  const updatedConfig = { ...config, url: convertParamToUrl(config.url) };
  window.webkit?.messageHandlers['native-inertia']?.postMessage(JSON.stringify(updatedConfig));

  // Wait for event that contains the real response
  const response = await new Promise(resolve => {
    handleInertiaEvent = event => resolve(event.detail);
    window.addEventListener('native-inertia', handleInertiaEvent);
  });

  // Remove the event listener after it's no longer needed
  window.removeEventListener('native-inertia', handleInertiaEvent);

  // Reuse the config object instead of creating a new one
  config.headers = {
    'content-type': 'application/json',
    'vary': 'X-Inertia',
    'x-inertia': 'true'
  };
  config.isFake = true;
  config.status = 200;
  config.statusText = 'OK';
  config.data = {
    ...response,
    version: 'current'
  };

  return config;
};

// Add a request interceptor
axios.interceptors.request.use(config => {
  return getFakeError(config);
}, error => Promise.reject(error));

// Add a response interceptor
axios.interceptors.response.use(response => response, error => {
  if (isFakeError(error)) {
    return getResponseFromEvent(error);
  }
});
