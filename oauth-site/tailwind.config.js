/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          teal: {
            50: '#f0fdfa',
            100: '#ccfbf1',
            200: '#99f6e4',
            300: '#5eead4',
            400: '#2dd4bf',
            500: '#14b8a6',
            600: '#0d9488',
            700: '#0f766e',
            800: '#115e59',
            900: '#134e4a',
            950: '#042f2e',
          },
          blue: {
            50: '#f0f9ff',
            100: '#e0f2fe',
            200: '#bae6fd',
            300: '#7dd3fc',
            400: '#38bdf8',
            500: '#0ea5e9',
            600: '#0284c7',
            700: '#0369a1',
            800: '#075985',
            900: '#0c4a6e',
            950: '#082f49',
          },
          sunrise: {
            gold: '#fbbf24',
            amber: '#f59e0b',
            coral: '#fb7185',
            rose: '#f43f5e',
          },
        },
      },
      backgroundImage: {
        'sunrise-gradient': 'linear-gradient(135deg, #0d9488 0%, #0284c7 50%, #f59e0b 100%)',
        'sunrise-subtle': 'linear-gradient(180deg, #f0fdfa 0%, #f0f9ff 60%, #fffbeb 100%)',
        'sunrise-dark': 'linear-gradient(180deg, #042f2e 0%, #082f49 70%, #0a192f 100%)',
      },
    },
  },
  plugins: [],
}
