import api from '../api/axios';

export const getAnimales = () => api.get('/animales').then((r) => r.data);

export const createAnimal = (data) => api.post('/animales', data).then((r) => r.data);

export const deleteAnimal = (id) => api.delete(`/animales/${id}`).then((r) => r.data);
