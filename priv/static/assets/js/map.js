import L from 'leaflet';

export const Map = {
  mounted() {
    this.map = L.map(this.el).setView([-23.5505, -46.6333], 12); // São Paulo como exemplo
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map);
    // Murals markers will be added via pushEvent or update
  },
  updated() {
    // Optionally handle updates for new murals
  }
};
