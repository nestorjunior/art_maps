import L from 'leaflet';

// Fix para os ícones do Leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

export const Map = {
  mounted() {
    // Centro inicial (São Paulo)
    this.map = L.map(this.el).setView([-23.5505, -46.6333], 12);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map);

    // Zoom controls (top right)
    L.control.zoom({ position: 'topright' }).addTo(this.map);

    // Location button
    const locateBtn = L.control({ position: 'topright' });
    locateBtn.onAdd = (map) => {
      const btn = L.DomUtil.create('button', 'leaflet-bar leaflet-control leaflet-control-custom');
      btn.innerHTML = '📍';
      btn.title = 'Voltar para minha localização';
      btn.style.width = '34px';
      btn.style.height = '34px';
      btn.onclick = () => {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition((pos) => {
            map.setView([pos.coords.latitude, pos.coords.longitude], 15);
          });
        }
      };
      return btn;
    };
    locateBtn.addTo(this.map);

    // Marcador temporário para seleção de localização
    this.tempMarker = null;

    // Evento de clique no mapa para selecionar localização
    this.map.on('click', (e) => {
      const { lat, lng } = e.latlng;

      // Envia coordenadas para o LiveView
      this.pushEvent("map-clicked", { lat: lat, lng: lng });

      // Remove marcador temporário anterior se existir
      if (this.tempMarker) {
        this.map.removeLayer(this.tempMarker);
      }

      // Adiciona novo marcador temporário (vermelho)
      this.tempMarker = L.marker([lat, lng], {
        icon: L.icon({
          iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
          shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
          iconSize: [25, 41],
          iconAnchor: [12, 41],
          popupAnchor: [1, -34],
          shadowSize: [41, 41]
        })
      }).addTo(this.map);

      this.tempMarker.bindPopup('📍 Nova localização selecionada').openPopup();
    });

    // Adiciona pins dos murais
    this.updateMarkers();
  },

  updated() {
    // Atualiza marcadores quando murais mudam
    this.updateMarkers();
  },

  updateMarkers() {
    const muralsData = this.el.getAttribute('data-murals');
    if (muralsData) {
      try {
        const murals = JSON.parse(muralsData);

        // Remove todos os marcadores existentes (exceto o temporário)
        this.map.eachLayer((layer) => {
          if (layer instanceof L.Marker && layer !== this.tempMarker) {
            this.map.removeLayer(layer);
          }
        });

        // Adiciona novos marcadores
        murals.forEach(mural => {
          if (mural.latitude && mural.longitude) {
            const marker = L.marker([mural.latitude, mural.longitude]).addTo(this.map);
            marker.bindPopup(`<strong>${mural.title}</strong><br>${mural.description || ''}`);
            marker.on('click', () => {
              // Dispara evento LiveView para abrir sidebar
              this.pushEvent("mural-selected", { id: mural.id });
            });
          }
        });
      } catch (e) {
        console.error('Erro ao parsear murais:', e);
      }
    }
  }
};
