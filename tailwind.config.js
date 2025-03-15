module.exports = {
    content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/javascript/**/*.js',
        './app/javascript/**/*.jsx'
    ],
    theme: {
        extend: {
            colors: {
                'russian-violet': '#231942',
                'ultra-violet': '#5E548E',
                'lavander': '#9F86C0',
                'african-violet': '#9B7DA8',
                'lilac': '#BE95C4',
                'pink': '#E0B1CB',
                'eminence': '#71388A',
                'amethyst': '#9665AB',
                'indigo': '#440381',

                'english-violet': '#55445C',
                'raisin-black': '#322A36',

                'light-gray': '#EBEBEB',
                'timberwolf': '#D3D0CB',
            },
            fontFamily: {
                unbounded: ['Unbounded', 'sans-serif'],
                roboto: ['Roboto', 'sans-serif']
            },
        }
    }
}