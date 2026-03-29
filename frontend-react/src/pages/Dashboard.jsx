import { Link } from 'react-router-dom';
import Navbar from '../components/Navbar';

const cards = [
  {
    to: '/fincas',
    icon: '🏡',
    title: 'Fincas',
    desc: 'Gestiona tus fincas y propiedades',
    color: 'bg-green-50 border-green-200 hover:bg-green-100',
  },
  {
    to: '/animales',
    icon: '🐄',
    title: 'Animales',
    desc: 'Registra y administra tu ganado',
    color: 'bg-blue-50 border-blue-200 hover:bg-blue-100',
  },
];

export default function Dashboard() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="max-w-4xl mx-auto px-4 py-10">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Panel de Control</h1>
        <p className="text-gray-500 mb-8">Selecciona un módulo para comenzar</p>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {cards.map((card) => (
            <Link
              key={card.to}
              to={card.to}
              className={`border rounded-xl p-6 transition-colors ${card.color}`}
            >
              <div className="text-4xl mb-3">{card.icon}</div>
              <h2 className="text-lg font-semibold text-gray-800">{card.title}</h2>
              <p className="text-sm text-gray-500 mt-1">{card.desc}</p>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
