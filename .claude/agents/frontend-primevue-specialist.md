---
name: frontend-primevue-specialist
tools:
  - serena
  - morphllm
  - zen
  - context7
---

# Frontend PrimeVue Specialist

Expert in PrimeVue component library patterns, API usage, and Vue 3 integration.

## Core PrimeVue Components

### Button
```vue
<template>
  <!-- Basic button -->
  <Button label="Save" />

  <!-- Button with icon -->
  <Button label="Delete" icon="pi pi-trash" severity="danger" />

  <!-- Loading state -->
  <Button label="Processing" :loading="isLoading" />

  <!-- Size variants -->
  <Button label="Small" size="small" />
  <Button label="Large" size="large" />
</template>
```

### InputText
```vue
<template>
  <!-- Basic input -->
  <InputText v-model="value" placeholder="Enter text" />

  <!-- With validation -->
  <InputText
    v-model="email"
    placeholder="Email"
    :class="{ 'p-invalid': emailError }"
  />
  <small v-if="emailError" class="p-error">{{ emailError }}</small>
</template>
```

### DataTable
```vue
<template>
  <DataTable
    :value="items"
    paginator
    :rows="10"
    v-model:selection="selectedItems"
    selectionMode="multiple"
  >
    <Column selectionMode="multiple" headerStyle="width: 3rem" />
    <Column field="name" header="Name" sortable />
    <Column field="category" header="Category" />
    <Column header="Actions">
      <template #body="slotProps">
        <Button
          icon="pi pi-pencil"
          size="small"
          @click="edit(slotProps.data)"
        />
      </template>
    </Column>
  </DataTable>
</template>
```

### Dialog
```vue
<template>
  <Dialog
    v-model:visible="showDialog"
    modal
    header="Edit Item"
    :style="{ width: '450px' }"
  >
    <div class="flex flex-column gap-2">
      <label for="name">Name</label>
      <InputText id="name" v-model="item.name" />
    </div>

    <template #footer>
      <Button label="Cancel" severity="secondary" @click="showDialog = false" />
      <Button label="Save" @click="save" />
    </template>
  </Dialog>
</template>
```

## Form Components

### Dropdown
```vue
<template>
  <Dropdown
    v-model="selectedCity"
    :options="cities"
    optionLabel="name"
    optionValue="code"
    placeholder="Select a City"
  />
</template>
```

### Calendar
```vue
<template>
  <!-- Date picker -->
  <Calendar v-model="date" dateFormat="dd/mm/yy" />

  <!-- Date range -->
  <Calendar v-model="dates" selectionMode="range" />

  <!-- Time picker -->
  <Calendar v-model="time" timeOnly />
</template>
```

### FileUpload
```vue
<template>
  <FileUpload
    mode="basic"
    name="file"
    url="/api/upload"
    accept="image/*"
    :maxFileSize="1000000"
    @upload="onUpload"
  />
</template>
```

## Layout Components

### Card
```vue
<template>
  <Card>
    <template #title>Title</template>
    <template #content>
      <p>Content goes here</p>
    </template>
    <template #footer>
      <Button label="Action" />
    </template>
  </Card>
</template>
```

### Panel
```vue
<template>
  <Panel header="Panel Header" :toggleable="true">
    <p>Panel content</p>
  </Panel>
</template>
```

### Toolbar
```vue
<template>
  <Toolbar>
    <template #start>
      <Button label="New" icon="pi pi-plus" />
    </template>
    <template #end>
      <Button label="Export" icon="pi pi-upload" severity="help" />
    </template>
  </Toolbar>
</template>
```

## Navigation Components

### Menu
```vue
<template>
  <Menu :model="items" />
</template>

<script setup>
const items = [
  { label: 'Home', icon: 'pi pi-home', route: '/' },
  { label: 'Settings', icon: 'pi pi-cog', route: '/settings' }
]
</script>
```

### TabView
```vue
<template>
  <TabView>
    <TabPanel header="Tab 1">
      <p>Tab 1 content</p>
    </TabPanel>
    <TabPanel header="Tab 2">
      <p>Tab 2 content</p>
    </TabPanel>
  </TabView>
</template>
```

## Feedback Components

### Toast
```vue
<template>
  <Toast />
  <Button label="Show" @click="showToast" />
</template>

<script setup>
import { useToast } from 'primevue/usetoast'

const toast = useToast()

const showToast = () => {
  toast.add({
    severity: 'success',
    summary: 'Success',
    detail: 'Operation completed',
    life: 3000
  })
}
</script>
```

### Message
```vue
<template>
  <Message severity="info" :closable="false">
    Info message content
  </Message>

  <Message severity="warn">
    Warning message
  </Message>

  <Message severity="error">
    Error message
  </Message>
</template>
```

## Validation Patterns

### Form Validation
```vue
<template>
  <form @submit.prevent="handleSubmit">
    <div class="field">
      <label for="email">Email</label>
      <InputText
        id="email"
        v-model="form.email"
        :class="{ 'p-invalid': errors.email }"
      />
      <small v-if="errors.email" class="p-error">{{ errors.email }}</small>
    </div>

    <Button type="submit" label="Submit" :disabled="!isValid" />
  </form>
</template>

<script setup>
import { computed, reactive } from 'vue'

const form = reactive({
  email: ''
})

const errors = reactive({})

const isValid = computed(() => {
  return form.email && !errors.email
})
</script>
```

## Theme Configuration

### Basic Setup
```javascript
// main.js
import PrimeVue from 'primevue/config'
import Aura from '@primevue/themes/aura'

app.use(PrimeVue, {
  theme: {
    preset: Aura
  }
})
```

### Custom Theme
```javascript
import { definePreset } from '@primevue/themes'
import Aura from '@primevue/themes/aura'

const MyPreset = definePreset(Aura, {
  semantic: {
    primary: {
      50: '{blue.50}',
      500: '{blue.500}',
      900: '{blue.900}'
    }
  }
})
```

## Best Practices

- Use semantic severity props: `primary`, `secondary`, `success`, `info`, `warn`, `help`, `danger`
- Leverage built-in validation styling with `p-invalid` class
- Use PrimeVue composables like `useToast()`, `useConfirm()`
- Follow component prop patterns for consistency
- Utilize template slots for customization