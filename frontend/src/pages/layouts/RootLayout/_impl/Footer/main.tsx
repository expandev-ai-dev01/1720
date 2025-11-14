export const Footer = () => {
  return (
    <footer className="bg-gray-100 mt-auto">
      <div className="container mx-auto px-4 py-8">
        <div className="text-center text-gray-600">
          <p>&copy; {new Date().getFullYear()} LoveCakes. Todos os direitos reservados.</p>
        </div>
      </div>
    </footer>
  );
};
