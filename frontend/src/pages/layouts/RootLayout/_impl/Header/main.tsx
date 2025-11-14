import { Link } from 'react-router-dom';

export const Header = () => {
  return (
    <header className="bg-white shadow-sm">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <Link to="/" className="text-2xl font-bold text-pink-600">
            LoveCakes
          </Link>
          <nav className="flex items-center gap-6">
            <Link to="/" className="text-gray-700 hover:text-pink-600 transition-colors">
              Início
            </Link>
            <Link to="/produtos" className="text-gray-700 hover:text-pink-600 transition-colors">
              Produtos
            </Link>
          </nav>
        </div>
      </div>
    </header>
  );
};
