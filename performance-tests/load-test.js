
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '1m',
};

export default function () {
  const url = `${__ENV.BASE_URL}/api/notifications/send`;

  const payload = JSON.stringify({
    email: 'jesuscastrodeleon02@gmail.com',
    asunto: 'Prueba de carga K6',
    mensaje: 'Notificacion generada durante la prueba de rendimiento.',
  });

  const response = http.post(url, payload, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${__ENV.TOKEN}`,
    },
    tags: {
      endpoint: 'api/notifications/send',
    },
  });

  check(response, {
    'respuesta HTTP 202': (r) => r.status === 202,
  });

  // Pausa para limitar el volumen de correos reales.
  sleep(5);
}
