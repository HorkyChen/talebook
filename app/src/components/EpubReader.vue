<template>
  <div ref="container" class="reader-container"></div>
</template>

<script>
import { defineComponent, onMounted, onBeforeUnmount, ref, watch } from 'vue'
import { createRoot } from 'react-dom/client'
import { ReactReader } from 'react-reader'
import React from 'react'

export default defineComponent({
  name: 'EpubReader',
  props: {
    url: {
      type: String,
      required: true
    },
    location: {
      type: String,
      default: null
    },
    tocChanged: {
      type: Function,
      default: () => {}
    }
  },
  emits: ['locationChanged'],
  setup(props, { emit }) {
    const container = ref(null)
    let root = null

    const renderReactComponent = () => {
      if (!container.value) return

      // Create React element
      const element = React.createElement(ReactReader, {
        url: props.url,
        location: props.location,
        locationChanged: (loc) => emit('locationChanged', loc),
        tocChanged: props.tocChanged,
        getRendition: (rendition) => {
          rendition.themes.register('custom', {
            body: {
              color: '#000',
              background: '#fff'
            }
          })
          rendition.themes.select('custom')
        }
      })

      // Render React component
      root = createRoot(container.value)
      root.render(element)
    }

    onMounted(() => {
      renderReactComponent()
    })

    onBeforeUnmount(() => {
      if (root) {
        root.unmount()
      }
    })

    // Re-render on prop changes
    watch(() => props.url, renderReactComponent)
    watch(() => props.location, renderReactComponent)

    return { container }
  }
})
</script>

<style scoped>
.reader-container {
  width: 100%;
  height: 100%;
  min-height: 500px;
  position: relative;
}
</style>