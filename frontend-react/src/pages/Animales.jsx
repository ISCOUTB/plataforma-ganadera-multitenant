import { useState, useEffect, useCallback } from 'react';
import Navbar from '../components/Navbar';
import { getAnimales, createAnimal, deleteAnimal } from '../animales/animales.service';

const EMPTY_FORM = {
  numero_identificacion: '',
  fecha_nacimiento: '',
  genero: 'm',
  peso: '',
  raza: '',
};

const GENERO_LABEL = { m: 'Macho', h: 'Hembra', n: 'No definido' };

export default function Animales() {
  const [animales, setAnimales] = useState([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      setAnimales(await getAnimales());
    } catch {
      setError('No se pudieron cargar los animales');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError('');
    try {
      await createAnimal({
        numero_identificacion: form.numero_identificacion.trim(),
        fecha_nacimiento: form.fecha_nacimiento,
        genero: form.genero,
        peso: parseFloat(form.peso),
        raza: form.raza.trim(),
      });
      setForm(EMPTY_FORM);
      setShowForm(false);
      await load();
    } catch (err) {
      const msg = err.response?.data?.message;
      setError(Array.isArray(msg) ? msg.join(', ') : (msg || 'Error al registrar el animal'));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id) {
    if (!confirm(`¿Eliminar el animal #${id}?`)) return;
    try {
      await deleteAnimal(id);
      await load();
    } catch {
      setError('No se pudo eliminar el animal');
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="max-w-5xl mx-auto px-4 py-8">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-800">Animales</h1>
          <button
            onClick={() => { setShowForm(!showForm); setError(''); }}
            className="bg-green-700 hover:bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          >
            {showForm ? '✕ Cancelar' : '+ Nuevo Animal'}
          </button>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3 mb-4">
            {error}
          </div>
        )}

        {showForm && (
          <form onSubmit={handleSubmit} className="bg-white border border-gray-200 rounded-xl p-6 mb-6 shadow-sm">
            <h2 className="text-base font-semibold text-gray-700 mb-4">Nuevo Animal</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Identificación *
                </label>
                <input
                  required
                  value={form.numero_identificacion}
                  onChange={(e) => setForm({ ...form, numero_identificacion: e.target.value })}
                  placeholder="BOV-2024-001"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Fecha de nacimiento *
                </label>
                <input
                  required
                  type="date"
                  value={form.fecha_nacimiento}
                  onChange={(e) => setForm({ ...form, fecha_nacimiento: e.target.value })}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Género *
                </label>
                <select
                  value={form.genero}
                  onChange={(e) => setForm({ ...form, genero: e.target.value })}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 bg-white"
                >
                  <option value="m">Macho</option>
                  <option value="h">Hembra</option>
                  <option value="n">No definido</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Peso (kg) *
                </label>
                <input
                  required
                  type="number"
                  min="0"
                  step="0.1"
                  value={form.peso}
                  onChange={(e) => setForm({ ...form, peso: e.target.value })}
                  placeholder="450.5"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Raza *
                </label>
                <input
                  required
                  value={form.raza}
                  onChange={(e) => setForm({ ...form, raza: e.target.value })}
                  placeholder="Brahman"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
            <div className="mt-4 flex justify-end">
              <button
                type="submit"
                disabled={submitting}
                className="bg-green-700 hover:bg-green-600 disabled:bg-green-300 text-white px-5 py-2 rounded-lg text-sm font-medium transition-colors"
              >
                {submitting ? 'Guardando...' : 'Registrar Animal'}
              </button>
            </div>
          </form>
        )}

        {loading ? (
          <div className="text-center py-12 text-gray-400">Cargando animales...</div>
        ) : animales.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            <div className="text-4xl mb-2">🐄</div>
            <p>No hay animales registrados. Registra el primero.</p>
          </div>
        ) : (
          <div className="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 text-gray-600 text-xs uppercase">
                <tr>
                  <th className="px-4 py-3 text-left">ID</th>
                  <th className="px-4 py-3 text-left">Identificación</th>
                  <th className="px-4 py-3 text-left">Raza</th>
                  <th className="px-4 py-3 text-left">Género</th>
                  <th className="px-4 py-3 text-right">Peso (kg)</th>
                  <th className="px-4 py-3 text-left">Nacimiento</th>
                  <th className="px-4 py-3 text-center">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {animales.map((a) => (
                  <tr key={a.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-gray-400 text-xs">#{a.id}</td>
                    <td className="px-4 py-3 font-medium text-gray-800">{a.numero_identificacion}</td>
                    <td className="px-4 py-3 text-gray-600">{a.raza}</td>
                    <td className="px-4 py-3">
                      <span className={`text-xs px-2 py-0.5 rounded-full ${
                        a.genero === 'm' ? 'bg-blue-100 text-blue-700' :
                        a.genero === 'h' ? 'bg-pink-100 text-pink-700' :
                        'bg-gray-100 text-gray-600'
                      }`}>
                        {GENERO_LABEL[a.genero] ?? a.genero}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right text-gray-600">{a.peso}</td>
                    <td className="px-4 py-3 text-gray-500">
                      {a.fecha_nacimiento ? new Date(a.fecha_nacimiento).toLocaleDateString('es-CO') : '—'}
                    </td>
                    <td className="px-4 py-3 text-center">
                      <button
                        onClick={() => handleDelete(a.id)}
                        className="text-red-500 hover:text-red-700 text-xs px-2 py-1 rounded hover:bg-red-50 transition-colors"
                      >
                        Eliminar
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
