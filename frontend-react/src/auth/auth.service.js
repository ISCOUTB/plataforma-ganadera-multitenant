import api from '../api/axios';

export async function login(email, password) {
  const { data } = await api.post('/auth/login', { email, password });
  localStorage.setItem('access_token', data.access_token);
  return data;
}

export function logout() {
  localStorage.removeItem('access_token');
}

export function getToken() {
  return localStorage.getItem('access_token');
}
