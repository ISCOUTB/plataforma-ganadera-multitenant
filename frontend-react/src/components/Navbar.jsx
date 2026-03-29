import { Link, useNavigate } from 'react-router-dom';
import { logout } from '../auth/auth.service';

export default function Navbar() {
  const navigate = useNavigate();

  function handleLogout() {
    logout();
    navigate('/login');
  }

  return (
    <nav className="bg-green-700 text-white px-6 py-3 flex items-center justify-between shadow">
      <div className="flex items-center gap-2">
        <span className="text-xl font-bold">🐄 FarmLink</span>
      </div>
      <div className="flex items-center gap-6">
        <Link to="/dashboard" className="hover:text-green-200 transition-colors">
          Dashboard
        </Link>
        <Link to="/fincas" className="hover:text-green-200 transition-colors">
          Fincas
        </Link>
        <Link to="/animales" className="hover:text-green-200 transition-colors">
          Animales
        </Link>
        <button
          onClick={handleLogout}
          className="bg-green-900 hover:bg-green-800 px-3 py-1 rounded text-sm transition-colors"
        >
          Salir
        </button>
      </div>
    </nav>
  );
}
