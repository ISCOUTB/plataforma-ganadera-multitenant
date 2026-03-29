import api from '../api/axios';

export const getFincas = () => api.get('/fincas').then((r) => r.data);

export const createFinca = (data) => api.post('/fincas', data).then((r) => r.data);

export const deleteFinca = (id) => api.delete(`/fincas/${id}`).then((r) => r.data);
