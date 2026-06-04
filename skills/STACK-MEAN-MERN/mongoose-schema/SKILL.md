---
name: mongoose-schema
description: "Trigger: mongoose schema, mongodb model, mongoose validation, mongoose hooks, mongoose indexes. Mongoose ODM patterns for MongoDB schema definition, validation, indexes, lifecycle hooks, query builders, and soft delete patterns."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Mongoose Schema Skill

> Patterns for defining MongoDB schemas with Mongoose including validation, indexes, hooks, and query optimization.

## Trigger Words

`mongoose schema`, `mongodb model`, `mongoose validation`, `mongoose hooks`, `mongoose indexes`, `mongoose query`, `mongoose middleware`

## References

- `database-schema-design` — General database schema design principles

## Schema Definition

### Basic Schema

```typescript
import mongoose, { Schema, Document } from 'mongoose';

interface IUser extends Document {
  email: string;
  name: string;
  role: 'user' | 'admin';
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user'
    }
  },
  {
    timestamps: true,  // Adds createdAt and updatedAt
    collection: 'users'
  }
);

export const User = mongoose.model<IUser>('User', UserSchema);
```

### Schema with Subdocuments

```typescript
const AddressSchema = new Schema({
  street: String,
  city: String,
  country: String,
  postalCode: String
});

const OrderSchema = new Schema({
  items: [{
    productId: { type: Schema.Types.ObjectId, ref: 'Product' },
    quantity: { type: Number, min: 1 },
    price: Number
  }],
  shippingAddress: AddressSchema,
  status: {
    type: String,
    enum: ['pending', 'shipped', 'delivered'],
    default: 'pending'
  }
});
```

## Validation

### Built-in Validators

```typescript
const ProductSchema = new Schema({
  name: {
    type: String,
    required: [true, 'Product name is required'],
    trim: true,
    minlength: [3, 'Name must be at least 3 characters'],
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative'],
    max: [1000000, 'Price exceeds maximum allowed']
  },
  category: {
    type: String,
    enum: {
      values: ['electronics', 'clothing', 'food', 'books'],
      message: '{VALUE} is not a valid category'
    }
  },
  email: {
    type: String,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email']
  },
  age: {
    type: Number,
    min: 0,
    max: 150
  }
});
```

### Custom Validators

```typescript
const EmployeeSchema = new Schema({
  startDate: {
    type: Date,
    validate: {
      validator: function(v: Date) {
        return v <= new Date();
      },
      message: 'Start date cannot be in the future'
    }
  },
  emergencyContact: {
    type: String,
    validate: {
      validator: function(v: string) {
        return /^[\d\-\+\(\) ]+$/.test(v);
      },
      message: 'Invalid phone number format'
    }
  }
});
```

### Validation Errors

```typescript
try {
  const user = new User({ email: 'invalid-email' });
  await user.save();
} catch (error) {
  if (error instanceof mongoose.Error.ValidationError) {
    Object.keys(error.errors).forEach(key => {
      console.log(`${key}: ${error.errors[key].message}`);
    });
  }
}
```

## Indexes

### Single Field Index

```typescript
const UserSchema = new Schema({
  email: { type: String, required: true },
  name: { type: String, required: true },
  createdAt: Date
});

// Explicit index
UserSchema.index({ email: 1 }, { unique: true });
UserSchema.index({ createdAt: -1 });  // Descending
```

### Compound Index

```typescript
const OrderSchema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User' },
  status: String,
  createdAt: Date,
  total: Number
});

// Compound index for common query pattern
OrderSchema.index({ userId: 1, status: 1, createdAt: -1 });

// For text search
const ProductSchema = new Schema({
  name: String,
  description: String
});
ProductSchema.index({ name: 'text', description: 'text' });
```

### Index Options

```typescript
UserSchema.index(
  { email: 1 },
  {
    unique: true,
    sparse: true,         // Only for documents where field exists
    background: true,      // Don't block other operations
    name: 'email_unique'   // Custom index name
  }
);
```

### Geospatial Index

```typescript
const LocationSchema = new Schema({
  name: String,
  location: {
    type: String,
    enum: ['Point'],
    required: true
  },
  coordinates: {
    type: [Number],  // [longitude, latitude]
    required: true
  }
});

LocationSchema.index({ location: '2dsphere' });
```

## Hooks (Middleware)

### Pre Hooks

```typescript
// Pre-save hook
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();

  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Pre-validate hook (runs before validators)
UserSchema.pre('validate', function(next) {
  if (this.role === 'admin' && !this.isAdminConfirmed) {
    next(new Error('Admin must be confirmed before saving'));
  } else {
    next();
  }
});

// Pre-find hook
UserSchema.pre('find', function(next) {
  console.log('About to run find query');
  next();
});

UserSchema.pre('findOne', function(next) {
  this.where({ deletedAt: { $exists: false } });
  next();
});
```

### Post Hooks

```typescript
// Post-save hook
UserSchema.post('save', function(doc) {
  console.log(`User ${doc._id} was saved`);
  // Send welcome email, etc.
});

// Post-remove hook
UserSchema.post('findOneAndDelete', async function(doc) {
  if (doc) {
    await AuditLog.create({
      action: 'user_deleted',
      userId: doc._id,
      timestamp: new Date()
    });
  }
});
```

### Hook Best Practices

```typescript
// Use arrow functions to preserve 'this'
UserSchema.pre('save', async function() {
  // 'this' is the document being saved
  if (this.isModified('email')) {
    await EmailVerification.create({
      userId: this._id,
      newEmail: this.email
    });
  }
});

// Error handling in hooks
UserSchema.pre('save', async function(next) {
  try {
    const existing = await this.constructor.findOne({ email: this.email });
    if (existing && existing._id.toString() !== this._id.toString()) {
      throw new Error('Email already in use');
    }
    next();
  } catch (error) {
    next(error as Error);
  }
});
```

## Query Patterns

### Common Query Methods

```typescript
// Find by ID (uses caching)
const user = await User.findById(id);

// Find one
const user = await User.findOne({ email: 'test@example.com' });

// Find many
const activeUsers = await User.find({ status: 'active' })
  .select('name email')                    // Projection
  .sort({ createdAt: -1 })                  // Sort
  .skip(20)                                // Pagination
  .limit(10)
  .lean();                                 // Plain JS objects

// Counting
const count = await User.countDocuments({ role: 'admin' });
const exists = await User.exists({ email: 'test@example.com' });
```

### Populate and Select

```typescript
// Populate references
const orders = await Order.find()
  .populate('userId', 'name email')         // Select specific fields
  .populate({
    path: 'items.productId',
    select: 'name price',
    match: { available: true }              // Filter within populated
  })
  .select('status total items');

// Selective population
const user = await User.findById(id)
  .populate({
    path: 'posts',
    perDocumentLimit: 10,                  // Limit per document
    options: { sort: { createdAt: -1 } }
  });
```

### Aggregation Pipeline

```typescript
const stats = await Order.aggregate([
  { $match: { status: 'completed' } },
  { $group: {
      _id: '$userId',
      totalSpent: { $sum: '$total' },
      orderCount: { $sum: 1 },
      avgOrderValue: { $avg: '$total' }
    }
  },
  { $sort: { totalSpent: -1 } },
  { $limit: 10 },
  { $lookup: {                       // Join with users
      from: 'users',
      localField: '_id',
      foreignField: '_id',
      as: 'user'
    }
  },
  { $unwind: '$user' },
  { $project: {                      // Reshape output
      _id: 0,
      userName: '$user.name',
      totalSpent: 1,
      orderCount: 1
    }
  }
]);
```

## Soft Delete

### Soft Delete Pattern

```typescript
const SoftDeleteSchema = new Schema({}, { timestamps: true, minimize: false });

SoftDeleteSchema.add({
  deletedAt: {
    type: Date,
    default: null
  },
  deletedBy: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    default: null
  }
});

// Query scope - automatically exclude soft deleted
SoftDeleteSchema.methods.isDeleted = function() {
  return this.deletedAt != null;
};

// Static method for soft delete
SoftDeleteSchema.statics.softDelete = async function(id: string, deletedBy: string) {
  return this.findByIdAndUpdate(id, {
    deletedAt: new Date(),
    deletedBy
  });
};

// Static method to find non-deleted
SoftDeleteSchema.statics.findActive = function(filter = {}) {
  return this.find({ ...filter, deletedAt: null });
};
```

### Global Query Hook for Soft Delete

```typescript
SoftDeleteSchema.pre(/^find/, function() {
  // Only add if not already excluded
  if (!this.getQuery().deletedAt) {
    this.where({ deletedAt: null });
  }
});
```

### Hard Delete with Validation

```typescript
// Only allow hard delete for specific conditions
async function hardDeleteUser(id: string): Promise<boolean> {
  const user = await User.findById(id);
  if (!user) return false;

  // Check if user has active orders
  const activeOrders = await Order.countDocuments({
    userId: id,
    status: { $in: ['pending', 'shipped'] }
  });

  if (activeOrders > 0) {
    throw new Error('Cannot delete user with active orders');
  }

  // Perform hard delete
  await User.findByIdAndDelete(id);
  await AuditLog.create({
    action: 'user_hard_deleted',
    userId: id,
    timestamp: new Date()
  });

  return true;
}
```

## Schema Best Practices

- [ ] Use `timestamps: true` for createdAt/updatedAt
- [ ] Define indexes for frequently queried fields
- [ ] Use `lean()` for read-only queries
- [ ] Handle validation errors with try/catch
- [ ] Use pre-hooks for data transformation
- [ ] Implement soft delete for critical data
- [ ] Use appropriate field types (ObjectId, Date, etc.)
- [ ] Set `minimize: false` when you need empty objects